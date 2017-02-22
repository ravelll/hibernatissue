require 'octokit'

class Issue
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

  def put_close_comment(issue)
    comment = <<COM
something message
for closing issue :construction_worker:
COM
    @client.add_comment(@repo, issue.to_hash[:number], comment)
  end
end
