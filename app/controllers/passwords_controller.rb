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

    redirect_to new_session_path, notice: "Istruzioni per il reset della password inviate (se l'utente con quella email esiste)."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.update(password_reset_token: nil, password_reset_sent_at: nil) # Invalida il token
      redirect_to new_session_path, notice: "La password è stata resettata."
    else
      redirect_to edit_password_path(params[:token]), alert: "Le password non corrispondono."
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(password_reset_token: params[:token])

    if @user.nil? || @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_path, alert: "Link per il reset della password non valido o scaduto."
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

