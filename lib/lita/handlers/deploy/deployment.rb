require 'octokit'
require 'action_view'
require 'action_view/helpers'

module Lita
  module Handlers
    class Deploy < Handler
      class Deployment
        include ActionView::Helpers::DateHelper

        attr_accessor :room
        attr_reader :user, :environment

        def initialize(user, branch_config, environment = nil)
          branch_config += ':' unless /:/.match(branch_config)
          @user = user
          @branch_config = branch_config
          @environment = environment
        end

        def branch
          @branch ||= @branch_config.split(':').last
        end

        def repo
          return @repo if @repo
          name = @branch_config.split(':').first
          name = "#{organization}/#{name}" unless /[a-z0-9\._-]+\/[a-z0-9\._-]+/
                                                  .match(name)
          @repo = name
        end

        def latest
          client.deployments(repo).map do |deployment|
            ref = "#{deployment.ref} (#{deployment.sha[0..7]})"

            if deployment[:ref] == deployment[:sha][0..7]
              ref = deployment[:ref]

              if /auto deploy triggered by a commit status change/.match(deployment.description)
                ref += " (auto-deploy)"
              end
            end

            {
              ref: ref,
              login: deployment.creator.login,
              environment: deployment.environment,
              time_ago: time_ago_in_words(deployment.created_at)
            }
          end
        rescue => e
          if /Not Found/.match(e.message)
            raise "I couldn't find any deployments for #{repo}."
          end
          raise e
        end

        def environments
          redis.smembers("#{repo}:environments")
        end

        def required_contexts
          nil
        end

        def payload
          {
            repository: repo,
            notify: {
              room: room,
              user: user.id
            }
          }
        end

        def post
          client.create_deployment(repo, branch,
                                   environment: environment,
                                   required_contexts: required_contexts,
                                   payload: JSON.dump(payload))
          return "Deployment of #{repo} to #{environment} created"
        rescue => e
          body_message = e.message

          if /No successful commit statuses/.match(body_message)
            return "I don't see a successful build for #{repo} that covers " \
                   "the latest \"#{branch}\" branch."
          end

          if /Conflict merging ([-_\.0-9a-z]+)/.match(body_message)
            default_branch = /Conflict merging ([-_\.0-9a-z]+)/
                             .match(body_message)[1]
            return "There was a problem merging the #{default_branch} " \
                   "for #{repo} into #{branch}. You'll need to merge it " \
                   'manually, or disable auto-merging.'
          end

          if /Merged ([-_\.0-9a-z]+) into/.match(body_message)
            return "Successfully merged the default branch for #{repo} into " \
                   "#{branch}. Normal push notifications should provide " \
                   'feedback.'
          end

          if /No ref found/.match(body_message)
            return "I couldn't find any \"#{branch}\" ref."
          end

          if /Not Found/.match(body_message)
            return "I can't create deployments for #{repo}. Check your " \
                   'scopes for this token.'
          end

          return body_message
        end

        def add_environment(environment)
          redis.sadd("#{repo}:environments", environment)
        end

        def self.register_token(user, token)
          User.create(user.id, github_key: token)
        end

        def self.forget_token(user)
          User.create(user.id, github_key: nil)
        end

        private

        def client
          @client ||= Octokit::Client.new(access_token: token)
        end

        def redis
          @redis ||= Redis::Namespace.new("deploy:deployment",
                                          redis: Lita.redis)
        end

        def token
          fail "I don\'t know you key to access Github.\n" \
               "You can tell me with 'my deploy token is ABC'\n" \
               "To create a new one, go to https://github.com/settings/tokens" \
               if !user.metadata.key?('github_key') || user.metadata['github_key'].empty?

          user.metadata['github_key']
        end

        def organization
          Lita.config.handlers.deploy.organization
        end
      end
    end
  end
end
