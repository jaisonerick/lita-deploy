require 'spec_helper'

describe Lita::Handlers::DeployQueue, lita_handler: true do
  it { is_expected.to route('lita queue me').to(:queue_me) }
  it { is_expected.to route('lita unqueue me').to(:unqueue_me) }
  it { is_expected.to route('lita queue next').to(:queue_next) }
  it { is_expected.to route('lita queue').to(:queue_list) }
end
