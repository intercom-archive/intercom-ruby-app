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

      def add_home_index_route
        route "root :to => 'home#index'"
      end

    end
  end
end
