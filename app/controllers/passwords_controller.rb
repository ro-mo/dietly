class PasswordsController < ApplicationController
  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    
    if user
      user.update!(
        password_reset_token: SecureRandom.hex(20), # Token più lungo per maggiore sicurezza
        password_reset_sent_at: Time.current
      )
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Istruzioni per il reset della password inviate (se l'utente con quella email esiste)."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.update!(password_reset_token: nil, password_reset_sent_at: nil) # Invalida il token dopo il reset
      redirect_to new_session_path, notice: "La password è stata resettata con successo."
    else
      flash.now[:alert] = "Errore nel reset della password. Assicurati che le password coincidano."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(password_reset_token: params[:token])

    if @user.nil?
      redirect_to new_password_path, alert: "Token non valido o già usato." and return
    end

    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_path, alert: "Il link per il reset è scaduto." and return
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

