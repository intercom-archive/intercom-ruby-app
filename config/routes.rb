IntercomApp::Engine.routes.draw do
  controller :sessions do
    get 'login' => :login, :as => :login
    get 'auth/intercom/callback' => :callback
    get 'logout' => :destroy, :as => :logout
  end

  namespace :webhooks do
    post ':type' => :receive
  end

  namespace :api do
    get ':path' => :proxy, :constraints => {:path => /.*/}
  end

end
