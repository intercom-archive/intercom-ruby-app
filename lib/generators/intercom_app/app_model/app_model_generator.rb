require 'rails/generators'

module IntercomApp
  module Generators
    class AppModelGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def create_app_model
        copy_file 'app.rb', 'app/models/app.rb'
      end

      def create_app_migration
        copy_migration 'create_apps.rb'
      end

      def create_session_storage_initializer
        copy_file 'intercom_session_repository.rb', 'config/initializers/intercom_session_repository.rb', force: true
      end

      def create_app_fixtures
        copy_file 'apps.yml', 'test/fixtures/apps.yml'
      end

      private

      def copy_migration(migration_name, config = {})
        migration_template(
          "db/migrate/#{migration_name}",
          "db/migrate/#{migration_name}",
          config
        )
      end

      # for generating a timestamp when using `create_migration`
      def self.next_migration_number(dir)
        ActiveRecord::Generators::Base.next_migration_number(dir)
      end
    end
  end
end
