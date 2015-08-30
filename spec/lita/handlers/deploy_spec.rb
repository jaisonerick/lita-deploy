require 'spec_helper'

describe Lita::Handlers::Deploy, lita_handler: true do
  let(:user_token) { 'da39a3ee5e6b4b0d3255bfef95601890afd80709' }
  let(:user) { Lita::User.create(123, github_key: user_token) }
  let(:github_company) { 'company' }
  let(:room) { 'developers' }

  before(:each) do
    Lita.config.handlers.deploy.organization = github_company
  end

  # Testing possible routes
  it { is_expected.to route('deploy repo').to(:deploy) }
  it { is_expected.to route('deploy repo:develop').to(:deploy) }
  it { is_expected.to route('deploy user/repo:develop').to(:deploy) }
  it { is_expected.to route('deploy user/repo:develop to dev').to(:deploy) }
  it { is_expected.to route('deploy user/repo:develop in dev').to(:deploy) }
  it { is_expected.to route('deploy user/repo:develop on dev').to(:deploy) }
  it { is_expected.to route('deploys for repo').to(:deploys) }
  it { is_expected.to route('deploys to repo').to(:deploys) }
  it { is_expected.to route('you can deploy repo to production').to(:add_environment) }
  it { is_expected.to route('you also can deploy repo to production').to(:add_environment) }
  it { is_expected.to route('you can deploy repo to production too').to(:add_environment) }
  it { is_expected.to route('my deploy key is da39a3ee5e6b4b0d3255bfef95601890afd80709').to(:register_token) }
  it { is_expected.to route('my deploy token is da39a3ee5e6b4b0d3255bfef95601890afd80709').to(:register_token) }
  it { is_expected.to route('forget my deploy token').to(:forget_token) }
  it { is_expected.to route('forget about my deploy token').to(:forget_token) }
  it { is_expected.to route('forget about my deploy key').to(:forget_token) }

  context 'successfully deploy' do
    it 'deploy repo to production' do
      stub_deployment_creation(repo: 'repo',
                               env: 'production',
                               full_repo: "#{github_company}/repo",
                               room: room,
                               user_id: user.id,
                               branch: 'master',
                               token: user_token)

      send_message('deploy repo to production', as: user)

      expect(replies.last)
        .to eq('Deployment of company/repo to production created')
    end

    it 'deploy organization/repo to production' do
      stub_deployment_creation(repo: 'repo',
                               env: 'production',
                               full_repo: 'organization/repo',
                               room: room,
                               user_id: user.id,
                               branch: 'master',
                               token: user_token)

      send_message('deploy organization/repo to production', as: user)

      expect(replies.last)
        .to eq('Deployment of organization/repo to production created')
    end

    it 'deploy organization/repo to development' do
      stub_deployment_creation(repo: 'repo',
                               env: 'development',
                               full_repo: 'organization/repo',
                               room: room,
                               user_id: user.id,
                               branch: 'master',
                               token: user_token)

      send_message('deploy organization/repo to development', as: user)

      expect(replies.last)
        .to eq('Deployment of organization/repo to development created')
    end

    it 'deploy organization/repo:develop to development' do
      stub_deployment_creation(repo: 'repo',
                               env: 'development',
                               full_repo: 'organization/repo',
                               room: room,
                               user_id: user.id,
                               branch: 'develop',
                               token: user_token)

      send_message('deploy organization/repo:develop to development', as: user)

      expect(replies.last)
        .to eq('Deployment of organization/repo to development created')
    end
  end
end
