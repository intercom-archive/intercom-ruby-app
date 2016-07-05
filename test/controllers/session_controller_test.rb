require 'test_helper'

module IntercomApp
  class SessionsControllerTest < ActionController::TestCase

    setup do
      @routes = IntercomApp::Engine.routes
      IntercomApp::SessionRepository.storage = InMemorySessionStore
      IntercomApp.configuration = nil
    end

    test "#login should " do
      auth_url = '/auth/intercom'
      get :login
      assert_match '<html><body>You are being <a href="http://test.host/login">redirected</a>.</body></html>', response.body
    end


    test "#callback should setup a intercom session" do
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

    private

    def mock_intercom_omniauth
      request.env['omniauth.auth'] = { 'uid': '1', 'credentials' => { 'token' => '1234='}, 'extra' => { 'raw_info' => { 'app' => { 'id_code' => 'abc123' } } } }  if request
    end
  end
end
