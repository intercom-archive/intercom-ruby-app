class HomeController < IntercomApp::AuthenticatedController

  def index
    # Example of an API request using intercom-ruby gem
    # Need 'read single admin' permission for the following request
    @me = intercom_client.admins.me
  end
end
