class HomeController < IntercomApp::AuthenticatedController

  def index
    # Example of an API request using intercom-ruby gem
    # Request 'read users' permission for the following request
    # @users_names = @intercom_client.users.find_all(:type=>'users', :per_page => 10, :page => 1, :order => "desc", :sort => "created_at").map(&:name)
  end
end
