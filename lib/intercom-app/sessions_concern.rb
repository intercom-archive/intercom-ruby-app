module IntercomApp
  module SessionsConcern
    extend ActiveSupport::Concern

    included do
      include IntercomApp::LoginProtection
    end

    def login
      store_in_session_before_login.call(session, params) if store_in_session_before_login
    end

    def callback
      if response = request.env['omniauth.auth']
        app = {
          intercom_token: response['credentials']['token'],
          intercom_app_id: response['extra']['raw_info']['app']['id_code'],
          name: response['extra']['raw_info']['name'],
          email: response['extra']['raw_info']['email']
        }
        app = app.merge(callback_hash.call(session, response)) if callback_hash
        session[:intercom] = IntercomApp::SessionRepository.store(app)
        session[:intercom_app_id] = app[:intercom_app_id]
        IntercomApp::WebhooksManager.new(intercom_token: app[:intercom_token]).create_webhooks_subscriptions if IntercomApp.configuration.webhooks.present?
        redirect_to return_address unless IntercomApp.configuration.oauth_modal
      else
        redirect_to login_url
      end
    end

    def destroy
      session[:intercom] = nil
      session[:intercom_app_id] = nil
      session[:intercom_token] = nil
      redirect_to login_url
    end

    private
    def return_address
      session.delete(:return_to) || '/'
    end

    def callback_hash
      IntercomApp.configuration.callback_hash
    end

    def store_in_session_before_login
      IntercomApp.configuration.store_in_session_before_login
    end
  end
end
