Rails.application.routes.draw do
  root :to => 'home#index'
  mount IntercomApp::Engine, at: '/'
end
