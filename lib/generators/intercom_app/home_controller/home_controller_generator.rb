require 'rails/generators/base'

module IntercomApp
  module Generators
    class HomeControllerGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_home_controller
        template 'home_controller.rb', 'app/controllers/home_controller.rb'
      end

      def create_home_index_view
        copy_file 'index.html.erb', 'app/views/home/index.html.erb'
      end

      def create_intercom_css
        copy_file 'intercom.css', 'app/assets/stylesheets/intercom.css'
        copy_file 'emoji.css', 'app/assets/stylesheets/emoji.css'
      end

      def create_logo
        copy_file 'logo.png', 'app/assets/images/logos/logo.png'
        copy_file 'intercom.png', 'app/assets/images/logos/intercom.png'
      end

      def create_application_view
        copy_file 'application.html.erb', 'app/views/layouts/application.html.erb'
      end

      def add_home_index_route
        route "root :to => 'home#index'"
      end

    end
  end
end
