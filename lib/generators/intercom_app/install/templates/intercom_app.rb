IntercomApp.configure do |config|
  config.app_key = "<%= @app_key %>"
  config.app_secret = "<%= @app_secret %>"
  config.oauth_modal = <%= @oauth_modal %>
end
