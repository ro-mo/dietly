class PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[new create edit update]
  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    
    if user
      if user.password_reset_locked_until&.future?
        redirect_to new_session_path, alert: "Troppi tentativi. Riprova più tardi."
        return
      end

      if user.password_reset_attempts.to_i >= 3
        user.update!(
          password_reset_locked_until: 1.hour.from_now,
          password_reset_attempts: 0
        )
        redirect_to new_session_path, alert: "Troppi tentativi. Riprova più tardi."
        return
      end

      user.update!(
        password_reset_token: SecureRandom.hex(20),
        password_reset_sent_at: Time.current,
        password_reset_attempts: user.password_reset_attempts.to_i + 1
      )

      PasswordsMailer.with(user: user, token: user.password_reset_token).reset.deliver_now
    end

    redirect_to new_session_path, notice: "Istruzioni per il reset della password inviate (se l'utente con quella email esiste)."
  end

  def edit
  end

  def update
    if @user.password_reset_sent_at < 15.minutes.ago
      redirect_to new_password_path, alert: "Il link per il reset è scaduto."
      return
    end

    if @user.update(password_params)
      @user.update!(
        password_reset_token: nil,
        password_reset_sent_at: nil,
        password_reset_attempts: 0,
        password_reset_locked_until: nil
      )
      redirect_to new_session_path, notice: "La password è stata resettata con successo."
    else
      flash.now[:alert] = "Errore nel reset della password. Assicurati che le password coincidano e rispettino i requisiti minimi."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(password_reset_token: params[:token])

    if @user.nil?
      redirect_to new_password_path, alert: "Token non valido o già usato."
      return
    end

    if @user.password_reset_locked_until&.future?
      redirect_to new_password_path, alert: "Questo link è stato bloccato per troppi tentativi. Richiedi un nuovo link."
      return
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

