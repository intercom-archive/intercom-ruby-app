require 'test_helper'
require 'generators/intercom_app/intercom_app_generator'

class IntercomAppGeneratorTest < Rails::Generators::TestCase
  tests IntercomApp::Generators::IntercomAppGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "intercom_app_generator runs" do
    run_generator
  end
end
