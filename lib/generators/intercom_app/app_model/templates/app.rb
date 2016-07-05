class App < ActiveRecord::Base
  include IntercomApp::App
  include IntercomApp::SessionStorage
end
