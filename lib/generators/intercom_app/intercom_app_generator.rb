module IntercomApp
  module Generators
    class IntercomAppGenerator < Rails::Generators::Base
      def initialize(args, *options)
        @opts = options.first
        super(args, *options)
      end

      def run_all_generators
        generate "intercom_app:install #{@opts.join(' ')}"
        generate "intercom_app:app_model"
        generate "intercom_app:home_controller"
      end
    end
  end
end
