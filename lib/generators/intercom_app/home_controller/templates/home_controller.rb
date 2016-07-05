class HomeController < ApplicationController
  def index
    @users_count = @intercom_client.users.all.count()
    @users_names = @intercom_client.users.all.map(&:name)
  end
end
