class RegistrationsController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    if Setting.current.registration_enabled?
      @user = User.new
    else
      render :disabled
    end
  end

  def create
    unless Setting.current.registration_enabled?
      render :disabled
      return
    end

    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Account created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.require(:user).permit(:username, :email_address, :password, :password_confirmation)
    end
end
