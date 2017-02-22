class Client
  def initialize(token, url)
    Octokit::configure do |c|
      c.api_endpoint = url || ''
    end
  end
end
