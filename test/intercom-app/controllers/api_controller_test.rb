require 'test_helper'
require 'action_controller'
require 'action_controller/base'

class ApiControllerTest < ActionController::TestCase

  setup do
    @controller = IntercomApp::SessionsController.new
    IntercomApp.configuration = nil
  end

  test "call remote api" do
    #stub_request(:any, "api.intercom.io").to_return(body: '{"foo": "bar"}')
    get :proxy, path: "users/123456"
    assert_response :success
    #assert_equal '{"foo": "bar"}' response.body
  end

end
