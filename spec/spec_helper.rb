require 'webmock/rspec'

require 'support/github_api'

require 'lita-deploy'
require 'lita/rspec'

# A compatibility mode is provided for older plugins upgrading from Lita 3.
# Since this plugin was generated with Lita 4, the compatibility mode should be
# left disabled.
Lita.version_3_compatibility_mode = false
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |c|
  c.include GithubApi
end
