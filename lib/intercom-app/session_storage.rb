module IntercomApp
  module SessionStorage
    extend ActiveSupport::Concern

    class_methods do
      def store(sess)
        app = self.find_or_initialize_by(intercom_app_id: sess[:intercom_app_id])
        sess.each {|k,v| app[k] = v}
        app.save!
        app.id
      end

      def retrieve(id)
        return unless id
        self.find_by(id: id)
      end
    end
  end
end
