module IntercomApp
  class AuthenticatedController < ApplicationController
    include IntercomApp::LoginProtection

    around_action :intercom_session
    layout 'application'
  end
end
