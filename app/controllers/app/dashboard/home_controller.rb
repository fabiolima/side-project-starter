# frozen_string_literal: true

# Handles the home page of user's dashboard.
class App::Dashboard::HomeController < ApplicationController
  before_action :authenticate_user!
  layout "user_administrator"
  def index; end
end
