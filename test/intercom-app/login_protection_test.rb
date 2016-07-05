require 'test_helper'
require 'action_controller'
require 'action_controller/base'

class LoginProtectionController < ActionController::Base
  include IntercomApp::LoginProtection
  helper_method :app_session

  around_action :intercom_session, only: [:index]

  def index
    render nothing: true
  end

  def raise_unauthorized
    raise ActiveResource::UnauthorizedAccess.new('unauthorized')
  end
end

class LoginProtectionTest < ActionController::TestCase
  tests LoginProtectionController

  setup do
    IntercomApp::SessionRepository.storage = InMemorySessionStore
  end

  test "calling app session returns nil when session is nil" do
    with_application_test_routes do
      session[:intercom] = nil
      get :index
      assert_nil @controller.app_session
    end
  end

  test "calling app session retreives session from storage" do
    with_application_test_routes do
      session[:intercom] = "foobar"
      get :index
      IntercomApp::SessionRepository.expects(:retrieve).returns(session).once
      assert @controller.app_session
    end
  end

  test "app session is memoized and does not retreive session twice" do
    with_application_test_routes do
      session[:intercom] = "foobar"
      get :index
      IntercomApp::SessionRepository.expects(:retrieve).returns(session).once
      assert @controller.app_session
      assert @controller.app_session
    end
  end


  test '#intercom_session with no Intercom session, redirects to the login url' do
    with_application_test_routes do
      get :index
      assert_redirected_to @controller.send(:main_or_engine_login_url)
    end
  end

  test '#intercom_session with no Intercom session, sets session[:return_to]' do
    with_application_test_routes do
      get :index
      assert_equal '/', session[:return_to]
    end
  end

  test '#intercom_session with no Intercom session, when the request is an XHR, returns an HTTP 401' do
    with_application_test_routes do
      get :index, xhr: true
      assert_equal 401, response.status
    end
  end

  private

  def with_application_test_routes
    with_routing do |set|
      set.draw do
        get '/' => 'login_protection#index'
        get '/raise_unauthorized' => 'login_protection#raise_unauthorized'
      end
      yield
    end
  end
end
