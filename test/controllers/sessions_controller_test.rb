require 'test_helper'

module IntercomApp
  class SessionsControllerTest < ActionController::TestCase

    setup do
      @routes = IntercomApp::Engine.routes
      IntercomApp::SessionRepository.storage = InMemorySessionStore
      IntercomApp.configuration = nil
    end

    test "#login" do
      get :login
      assert_match "  <a href=\"/auth/intercom\">\n    <img src=\"https://static.intercomassets.com/assets/oauth/primary-7edb2ebce84c088063f4b86049747c3a.png\" srcset=\"https://static.intercomassets.com/assets/oauth/primary-7edb2ebce84c088063f4b86049747c3a.png 1x, https://static.intercomassets.com/assets/oauth/primary@2x-0d69ca2141dfdfa0535634610be80994.png 2x, https://static.intercomassets.com/assets/oauth/primary@3x-788ed3c44d63a6aec3927285e920f542.png 3x\"/>\n  </a>\n", response.body
    end

    test "#login with oauth_modal config" do
      IntercomApp.configuration.oauth_modal = true

      get :login
      assert_match "<div class=\"card\"", response.body
    end


    test "#callback should setup an intercom session" do
      mock_intercom_omniauth

      get :callback
      assert_not_nil session[:intercom]
      assert_equal 'abc123', session[:intercom_app_id]
    end

    test "#destroy should clear intercom from session and redirect to login" do
      app_id = 1
      session[:intercom] = app_id
      session[:intercom_app_id] = 'abc123'

      get :destroy

      assert_nil session[:intercom]
      assert_nil session[:intercom_domain]
      assert_redirected_to login_path
    end

    test "#callback should start the WebhooksManager if webhooks are configured" do
      IntercomApp.configure do |config|
        config.webhooks = [{topic: ['users'], url: 'example-app.com/webhooks/users'}]
      end

      IntercomApp::WebhooksManager.any_instance.expects(:create_webhooks_subscriptions)

      mock_intercom_omniauth
      get :callback
    end

    test "#callback doesn't run the WebhooksManager if no webhooks are configured" do
      IntercomApp.configure do |config|
        config.webhooks = []
      end

      IntercomApp::WebhooksManager.any_instance.expects(:create_webhooks_subscriptions).never

      mock_intercom_omniauth
      get :callback
    end

    test "#callback closes popup if oauth_modal configuration" do
      IntercomApp.configuration.oauth_modal = true

      mock_intercom_omniauth
      get :callback
      assert_match "<html>\n  <head>\n    <title>Authorized</title>\n  </head>\n  <body>\n    <script type=\"text/javascript\">\n      setTimeout(function() {\n        if (window.opener) {\n          window.opener.oauth_success = true;\n        }\n        window.close();\n      }, 1000);\n    </script>\n  </body>\n</html>\n", response.body
    end

  end
end
