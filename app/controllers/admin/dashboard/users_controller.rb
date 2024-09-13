# frozen_string_literal: true

# Handles the user pages inside admin's dashboard.
class Admin::Dashboard::UsersController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_admin!
  layout "administrator"

  def index
    email = "%#{search_params[:search]}%"
    users = User.where("email LIKE ?", email).includes(:profile)

    @pagy, @users = pagy(users, limit: 10)
  end

  def show
    @user = User.includes(:profile).find(params[:id])

    subscriptions = Subscription.where(user: @user).includes(price: [:product]).order(created_at: :desc)
    @pagy, @subscriptions = pagy(subscriptions, limit: 1)
  end

  def destroy
    user = User.find(params[:id])
    user.destroy

    redirect_to admin_dashboard_users_path, notice: "#{user.email} has been deleted."
  end

  def ban
    user = User.find(params[:id])
    user.lock_access!

    redirect_to admin_dashboard_user_path(user), notice: "#{user.email} has been banned."
  end

  def unban
    user = User.find(params[:id])
    user.unlock_access!

    redirect_to admin_dashboard_user_path(user), notice: "#{user.email} has been unbanned."
  end

  private

  def search_params
    params.permit(:search)
  end
end
