module IntercomApp
  class App < ActiveResource::Base
    include IntercomApp::App
    include IntercomApp::SessionStorage
  end
end
