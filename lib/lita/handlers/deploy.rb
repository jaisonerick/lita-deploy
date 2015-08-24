require 'lita/handlers/deploy/deployment'

module Lita
  # Lita Handlers
  module Handlers
    # Handle all chat Deploy communication.
    #
    # == Configuration
    #
    # organization (Required):: The organization name of repositories to deploy
    # default_env (Defalt: production):: The default environment to deploy to.
    # default_room (Defalt: developers):: The default chat room to reply to.
    #
    # == Chat Routes
    #
    # deploy repo:master to staging:: Deploys Master in Staging environment.
    # deploy repo:feature/abc:: Deploys feature/abc in production environment.
    #
    class Deploy < Handler
      config :default_env, default: 'production'
      config :default_room, default: 'developers'
      config :organization, required: true

      # Route: deploy (what)( to (environment))?
      route(/^deploy (\S+)(?:\s+(?:to|in|on)\s+(\S+))?$/i, :deploy, help:
            { 'deploy repo:develop to staging' => 'Deploys develop in staging',
              'deploy repo:feature/abc' => 'Deploys feature/abc to production' })

      route(/^deploys (?:(?:for|to)\s+)?(\S+)$/i, :deploys, help:
            { 'deploys for repo' => 'Last deployments for repository' })

      route(/where can i deploy ([a-z0-9_-]+)\??$/i, :targets, help:
            { 'where can i deploy repo' => 'List repo available environments.' })

      route(/you (?:also )?can (?:also )?deploy (\S+) to (\S+)(?: (?:also|too))?/i,
            :add_environment, help:
            { 'you can deploy repo to production' => 'Add a new environment ' \
                                                     'for a repository' })

      route(/^my deploy (?:token|key) is ([a-f0-9]{40})$/i, :register_token, help:
            { 'my deploy token is (token)' => 'Register your github token' })

      route(/^forget (?:about )?my deploy (?:token|key)$/i, :forget_token, help:
            { 'forget my deploy token' => 'Clean you your github token' })

      def targets(response)
        repo = response.match_data[1]

        response.reply render_template('where',
                                       envs: Deployment.new(response.user, repo)
                                             .environments,
                                       repo: repo)
      end

      def register_token(response)
        token = response.match_data[1]
        Deployment.register_token(response.user, token)
        response.reply 'Got it!'
      end

      def forget_token(response)
        Deployment.forget_token(response.user)
        response.reply 'Don\'t worry, I have a short memory. It is forgotten.'
      end

      def add_environment(response)
        repo = response.match_data[1]
        environment = response.match_data[2]

        Deployment.new(response.user, repo).add_environment(environment)

        response.reply ['Ok', 'Got it', 'Nice', 'Thank you', 'Capice', 'Yay']
          .sample + "! Now I can deploy #{repo} to #{environment}"
      end

      def deploys(response)
        repo = response.match_data[1]
        deployments = Deployment.new(response.user, repo).latest
        response.reply render_template('latest_deployments',
                                       deployments: deployments,
                                       repo: repo)
      rescue => e
        response.reply e.message
      end

      def deploy(response)
        branch = response.match_data[1]
        environment = response.match_data[2] || config.default_env

        deployment = Deployment.new(response.user, branch, environment)
        deployment.room = response.message.source.room || config.default_room

        deployment_response = deployment.post
        response.reply deployment_response if deployment_response

        # msg = 'tmm1 is deploying github/my-feature (sha1) to production.'
        # msg = 'tmm1\'s production deployment of github/my-feature (sha1) is done! (82s)'
        # msg = 'tmm1, make sure you watch for exceptions in rollbar and perf issues at graphme'
      end
    end

    Lita.register_handler(Deploy)
  end
end
