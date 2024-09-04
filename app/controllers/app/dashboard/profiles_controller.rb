# frozen_string_literal: true

# Handle the profile page inside user's dashboard.
class App::Dashboard::ProfilesController < ApplicationController
  before_action :authenticate_user!
  layout "user_administrator"
  def edit
    @profile = current_user.profile
  end

  def update
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update update_params
        format.html { redirect_to edit_app_dashboard_profile_path(@profile), notice: "Profile successifully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def update_params
    params.require(:profile).permit(:first_name, :last_name)
  end
end
