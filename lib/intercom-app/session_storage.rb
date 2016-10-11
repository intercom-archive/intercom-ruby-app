module IntercomApp
  module SessionStorage
    extend ActiveSupport::Concern

    class_methods do
      def store(sess)
        app = self.find_or_initialize_by(intercom_app_id: sess[:intercom_app_id])
        app.intercom_token = sess[:intercom_token]
        app.save!
        app.id
      end

      def retrieve(id)
        return unless id
        if app = self.find_by(id: id)
          session = {
            id: app.id,
            intercom_app_id: app.intercom_app_id,
            intercom_token: app.intercom_token
          }
        end
      end
    end
  end
end
