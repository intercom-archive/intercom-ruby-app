IntercomApp::Engine.routes.draw do
  controller :sessions do
    get 'login' => :login, :as => :login
    get 'auth/intercom/callback' => :callback
    get 'logout' => :destroy, :as => :logout
  end

  namespace :webhooks do
    post ':type' => :receive
  end
end
