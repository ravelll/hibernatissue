require 'octokit'
require 'date'

class Hibernatissue
  def initialize
    Octokit::configure do |c|
      c.api_endpoint = 'https://github.enter.prise/api/v3/'
    end

    @repo = 'awesome/repos'
    @client = Octokit::Client.new(access_token: ENV['TOKEN'] || token)
    @client = client(token)
  end

  def client(token)
    Octokit::Client.new(token)
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
    ENV['TOKEN']
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
end
