class App::Dashboard::HomeController < ApplicationController
  before_action :authenticate_user!
  layout "user_administrator"
  def index; end
end
