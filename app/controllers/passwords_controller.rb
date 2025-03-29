class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      user.update(password_reset_token: SecureRandom.hex(10), password_reset_sent_at: Time.current) 
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.update(password_reset_token: nil, password_reset_sent_at: nil) # Invalida il token
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(password_reset_token: params[:token])

    if @user.nil? || @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

