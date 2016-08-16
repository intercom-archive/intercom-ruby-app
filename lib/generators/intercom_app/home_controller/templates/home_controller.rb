class HomeController < IntercomApp::AuthenticatedController

  def index
    @users_names = @intercom_client.users.find_all(:type=>'users', :per_page => 10, :page => 1, :order => "desc", :sort => "created_at").map(&:name)
  end
end
