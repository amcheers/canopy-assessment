require_relative './client.rb'
require 'json'

module Github
  class Processor
    # This class is responsible for processing the response from the Github API.
    # It accepts a client object and stores it as an instance variable.
    # It has a method called `issues` that returns a list of issues from the Github API.
    def initialize(client)
      @client = client
    end

    # Method to check if the second argument is a number and for page or state




    def issues(open: true, page: nil)
      # This method returns a list of issues from the Github API.
      # It accepts an optional argument called `open` that defaults to true.
      # If `open` is true, it returns only open issues.
      # If `open` is false, it returns only closed issues.
      # It makes a GET request to the Github API using the client object.
      # It returns the response from the Github API.

      # Return a list of issues from the response, with each line showing the issue's title, whether it is open or closed,
      # and the date the issue was closed if it is closed, or the date the issue was created if it is open.
      # the issues are sorted by the date they were closed or created, from newest to oldest.
      def parse_int(str)
        Integer(str)
      rescue ArgumentError, TypeError
        nil
      end

      maybe_page = parse_int(ARGV[1])
      #If page is a number set page and check for existence of ARGV[2] and it's value
      if maybe_page
        page  = maybe_page
        state = ARGV[2] && ARGV[2] == 'open' ? true : false
        #If page is not a number set page to nil and set interpret ARGV[1] as state
      else
        page  = nil
        state = ARGV[1] && ARGV[1] == 'open' ? true : false
      end



      issues = []
      if page
        (1..page).each do |page|
          response = @client.get("/issues?page=#{page}&state=#{state}")
          issues << JSON.parse(response.body)
        end
        issues
      else
        response = @client.get("/issues?state=#{state}")
        issues << JSON.parse(response.body)
        while response.headers['link'].present? && include?("rel=\"next\"")
          page += 1
          results = @client.get("/issues?page=#{page}&state=#{state}")
          issues << JSON.parse(results.body)
        end
        issues
      end
      end

      sorted_issues = issues.sort_by do |issue|
        if state == 'closed'
          issue['closed_at']
        else
          issue['created_at']
        end
      end.reverse
      
      sorted_issues.each do |issue|
        if issue['state'] == 'closed'
          puts "#{issue['title']} - #{issue['state']} - Closed at: #{issue['closed_at']}"
        else
          puts "#{issue['title']} - #{issue['state']} - Created at: #{issue['created_at']}"
        end
      end
    end
  end
end

# The URL to make API requests for the IBM organization and the jobs repository
# would be 'https://api.github.com/repos/ibm/jobs'.

Github::Processor.new(Github::Client.new(ENV['TOKEN'], ARGV[0])).issues(open: state, page: page)
