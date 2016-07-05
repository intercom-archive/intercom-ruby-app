require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  setup do
    IntercomApp.configuration = nil
  end

  test "configure" do
    IntercomApp.configure do |config|
      config.oauth_modal = true
    end

    assert_equal true, IntercomApp.configuration.oauth_modal
  end

end
