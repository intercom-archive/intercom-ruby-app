Rails.application.routes.draw do
  mount IntercomApp::Engine, at: '/'
  root to: "home#index"
end
