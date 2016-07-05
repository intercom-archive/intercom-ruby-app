module IntercomApp
  module LoginProtection
    extend ActiveSupport::Concern

    # included do
    #   rescue_from ActiveResource::UnauthorizedAccess, :with => :close_session
    # end

    def intercom_session
      if app_session
        begin
          @intercom_client = Intercom::Client.new(app_id: app_session[:token], api_key: '')
          yield
        end
      else
        redirect_to_login
      end
    end

    def app_session
      return unless session[:intercom]
      @intercom_session ||= IntercomApp::SessionRepository.retrieve(session[:intercom])
    end

    protected

    def redirect_to_login
      if request.xhr?
        head :unauthorized
      else
        session[:return_to] = request.fullpath if request.get?
        redirect_to_with_fallback main_or_engine_login_url
      end
    end

    def close_session
      session[:intercom] = nil
      session[:intercom_app_id] = nil
      redirect_to_with_fallback main_or_engine_login_url
    end

    def main_or_engine_login_url(params = {})
      main_app.login_url(params)
    rescue NoMethodError => e
      intercom_app.login_url(params)
    end

    def redirect_to_with_fallback(url)
      url_json = url.to_json
      url_json_no_quotes = url_json.gsub(/\A"|"\Z/, '')

      render inline: %Q(
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <title>Redirecting…</title>
            <script type="text/javascript">
              window.location.href = #{url_json};
            </script>
          </head>
          <body>
          </body>
        </html>
      ), status: 302, location: url
    end

    def fullpage_redirect_to(url)
      url_json = url.to_json
      url_json_no_quotes = url_json.gsub(/\A"|"\Z/, '')
      redirect_to_with_fallback url
    end
  end
end
