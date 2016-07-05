module IntercomApp
  module SessionsConcern
    extend ActiveSupport::Concern

    def login
      redirect_to login_url
    end

    def callback
      if response = request.env['omniauth.auth']
        app = {
          token: response['credentials']['token'],
          intercom_app_id: response['extra']['raw_info']['app']['id_code']
        }
        session[:intercom] = IntercomApp::SessionRepository.store(app)
        session[:intercom_app_id] = app[:intercom_app_id]
        redirect_to return_address unless IntercomApp.configuration.oauth_modal
      else
        redirect_to login_url
      end
    end

    def destroy
      session[:intercom] = nil
      session[:intercom_app_id] = nil
      redirect_to login_url
    end

    private
    def return_address
      session.delete(:return_to) || '/'
    end

  end
end
