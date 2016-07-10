class HomeController < ApplicationController
  around_filter :intercom_session

  def index
    @users_count = @intercom_client.users.all.count()
    @users_names = @intercom_client.users.all.map(&:name)
  end
end
