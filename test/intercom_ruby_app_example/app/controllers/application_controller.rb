class ApplicationController < ActionController::Base
  include IntercomApp::LoginProtection
end
