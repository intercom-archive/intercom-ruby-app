require 'test_helper'
require 'generators/intercom_app/home_controller/home_controller_generator'

class HomeControllerGeneratorTest < Rails::Generators::TestCase
  tests IntercomApp::Generators::HomeControllerGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  setup do
    prepare_destination
    provide_existing_application_file
    provide_existing_routes_file
    provide_existing_application_controller
  end

  test "creates the home controller" do
    run_generator
    assert_file "app/controllers/home_controller.rb"
  end

  test "adds home route to routes" do
    run_generator
    assert_file "config/routes.rb" do |routes|
      assert_match "mount IntercomApp::Engine, at: '/'", routes
      assert_match "root :to => 'home#index'", routes
    end
  end
end
