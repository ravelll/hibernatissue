require 'octokit'
require 'date'

class Hibernatissue
  def initialize
    Octokit::configure do |c|
      c.api_endpoint = 'https://github.enter.prise/api/v3/'
    end

    @repo = 'awesome/repos'
    @client = Octokit::Client.new(access_token: ENV['TOKEN'] || token)
  end

  def close!
    issues_to_close.each do |issue|
      put_close_comment(issue)

      puts "close issue: #{issue.to_hash[:title]}"
      @client.close_issue(@repo, issue.to_hash[:number])
    end
  end

  private

  def token
    File.read('./.access_token').chomp
  end

  def issues_to_close
    page = 1
    issues = []

    loop do
      issues_per_page = @client.list_issues(
        @repo, {state: 'open', sort: 'updated', direction: 'asc', page: page}
      )

      if updated_at_date(issues_per_page.first) > now_date - 31
        break
      else
        issues << issues_per_page
        page += 1
      end
    end

    issues
      .flatten
      .keep_if {|i| should_close?(i) && !exceptional?(i)}
  end

  def exceptional?(issue)
    issue.to_hash.has_key?(:pull_request) || issue.to_hash[:labels].any? {|l| l[:name] == 'exception_tag'}
  end

  def should_close?(issue)
    Date.parse(Time.now.to_s) - 31 > Date.parse(issue.to_hash[:updated_at].to_s)
  end

  def now_date
    Date.parse(Time.now.to_s)
  end

  def updated_at_date(issue)
    Date.parse(issue.to_hash[:updated_at].to_s)
  end

  def put_close_comment(issue)
    comment = <<COM
something message
for closing issue :construction_worker:
COM

    @client.add_comment(@repo, issue.to_hash[:number], comment)
  end
end
