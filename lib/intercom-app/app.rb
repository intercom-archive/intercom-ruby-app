module IntercomApp
  module App
    extend ActiveSupport::Concern

    included do
      validates :intercom_app_id, presence: true, uniqueness: true
      validates :intercom_token, presence: true
    end
  end
end
