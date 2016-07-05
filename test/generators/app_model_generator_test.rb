require 'test_helper'
require 'generators/intercom_app/app_model/app_model_generator'

class AppModelGeneratorTest < Rails::Generators::TestCase
  tests IntercomApp::Generators::AppModelGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "create the app model" do
    run_generator
    assert_file "app/models/app.rb" do |app|
      assert_match "class App < ActiveRecord::Base", app
      assert_match "include IntercomApp::App", app
      assert_match "include IntercomApp::SessionStorage", app
    end
  end

  test "creates AppModel migration" do
    run_generator
    assert_migration "db/migrate/create_apps.rb" do |migration|
      assert_match "create_table :apps  do |t|", migration
    end
  end

  test "adds the intercom_session_repository initializer" do
    run_generator
    assert_file "config/initializers/intercom_session_repository.rb" do |file|
      assert_match "IntercomApp::SessionRepository.storage = App", file
    end
  end

  test "creates default app fixtures" do
    run_generator
    assert_file "test/fixtures/apps.yml" do |file|
      assert_match "example_app:", file
    end
  end

end
