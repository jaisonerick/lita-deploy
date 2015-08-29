# Helpers to stub GithubApi
module GithubApi
  # Stub deployment creation
  # {https://developer.github.com/v3/repos/deployments/#create-a-deployment}
  def stub_deployment_creation(repo:, env:, full_repo:, room:, user_id:,
                               branch:, token:)
    request = { environment: env,
                required_contexts: nil,
                ref: branch,
                payload: { repository: full_repo,
                           notify: { room: room,
                                     user: user_id } } }

    response = {
      url: "https://api.github.com/repos/#{full_repo}/deployments/1",
      id: 1,
      sha: 'a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d',
      ref: branch,
      task: 'deploy',
      payload: request[:payload],
      environment: env,
      description: '',
      creator: {
        login: 'octocat',
        id: 1,
        avatar_url: 'https://github.com/images/error/octocat_happy.gif',
        gravatar_id: '',
        url: 'https://api.github.com/users/octocat',
        html_url: 'https://github.com/octocat',
        followers_url: 'https://api.github.com/users/octocat/followers',
        following_url: 'https://api.github.com/users/octocat/following{/other_user}',
        gists_url: 'https://api.github.com/users/octocat/gists{/gist_id}',
        starred_url: 'https://api.github.com/users/octocat/starred{/owner}{/repo}',
        subscriptions_url: 'https://api.github.com/users/octocat/subscriptions',
        organizations_url: 'https://api.github.com/users/octocat/orgs',
        repos_url: 'https://api.github.com/users/octocat/repos',
        events_url: 'https://api.github.com/users/octocat/events{/privacy}',
        received_events_url: 'https://api.github.com/users/octocat/received_events',
        type: 'User',
        site_admin: false
      },
      created_at: '2012-07-20T01:19:13Z',
      updated_at: '2012-07-20T01:19:13Z',
      statuses_url: "https://api.github.com/repos/#{full_repo}/deployments/1/statuses",
      repository_url: "https://api.github.com/repos/#{full_repo}" }

    stub_request(:post, "https://api.github.com/repos/#{full_repo}/deployments")
      .with(body: request,
            headers: { 'Authorization' => "token #{token}" })
      .to_return(status: 200, body: MultiJson.dump(response),
                 headers: { 'X-RateLimit-Limit': 5000,
                            'X-RateLimit-Remaining': 4999 })
  end
end
