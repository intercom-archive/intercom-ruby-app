if Rails.configuration.cache_classes
  IntercomApp::SessionRepository.storage = App
else
  ActionDispatch::Reloader.to_prepare do
    IntercomApp::SessionRepository.storage = App
  end
end
