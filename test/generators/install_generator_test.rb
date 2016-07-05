require 'test_helper'
require 'generators/intercom_app/install/install_generator'

class InstallGeneratorTest < Rails::Generators::TestCase
  tests IntercomApp::Generators::InstallGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  setup do
    prepare_destination
    provide_existing_application_file
    provide_existing_routes_file
    provide_existing_application_controller
  end

  test "creates the IntercomApp initializer" do
    run_generator
    assert_file "config/initializers/intercom_app.rb" do |intercom_app|
      assert_match 'config.app_key = "<app_key>"', intercom_app
      assert_match 'config.app_secret = "<app_secret>"', intercom_app
      assert_match 'config.oauth_modal = false', intercom_app
    end
  end

  test "creates the IntercomApp initializer with args" do
    run_generator %w(--app_key key --app_secret shhhhh --oauth_modal true)
    assert_file "config/initializers/intercom_app.rb" do |intercom_app|
      assert_match 'config.app_key = "key"', intercom_app
      assert_match 'config.app_secret = "shhhhh"', intercom_app
      assert_match "config.oauth_modal = true", intercom_app
    end
  end

  test "creats and injects into omniauth initializer" do
    run_generator
    assert_file "config/initializers/omniauth.rb" do |omniauth|
      assert_match "provider :intercom", omniauth
    end
  end

  test "creates the default intercom_session_repository" do
    run_generator
    assert_file "config/initializers/intercom_session_repository.rb" do |file|
      assert_match "IntercomApp::SessionRepository.storage = InMemorySessionStore", file
    end
  end

  test "injects into application controller" do
    run_generator
    assert_file "app/controllers/application_controller.rb" do |controller|
      assert_match "  include IntercomApp::LoginProtection\n", controller
    end
  end

  test "adds engine to routes" do
    run_generator
    assert_file "config/routes.rb" do |routes|
      assert_match "mount IntercomApp::Engine, at: '/'", routes
    end
  end
end
