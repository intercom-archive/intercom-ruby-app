module IntercomApp
  class AuthenticatedController < ApplicationController
    # before_action :login_again_if_different_app
    around_action :intercom_session
    layout 'application'
  end
end
