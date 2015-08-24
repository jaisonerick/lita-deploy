require 'spec_helper'

describe Lita::Handlers::Deploy, lita_handler: true do
  it { is_expected.to route('deploy feature/a') }
  it { is_expected.to route('deploy feature/a to development') }
end
