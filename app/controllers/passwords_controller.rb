class PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[new create edit update]
  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    @user = User.find_by(email_address: params[:email_address])
    if @user
      # Genera un nuovo token di reset
      expiration_time = 15.minutes.from_now
      token = SecureRandom.urlsafe_base64
      @user.update(
        password_reset_token: token,
        password_reset_sent_at: expiration_time
      )
      PasswordsMailer.with(user: @user, token: token).reset.deliver_later
      redirect_to new_session_path, notice: "Istruzioni per il reset della password inviate (se l'utente con quella email esiste)."
    else
      redirect_to new_password_path, alert: "Email non trovata"
    end
  end

  def edit
    if @user.nil?
      redirect_to new_password_path, alert: "Token non valido o già usato."
      return
    end

    if @user.password_reset_sent_at < 15.minutes.ago
      redirect_to new_password_path, alert: "Il link per il reset è scaduto."
      return
    end
  end

  def update
    if @user.password_reset_sent_at < 15.minutes.ago
      redirect_to new_password_path, alert: "Il link per il reset è scaduto."
      return
    end

    if params[:password].blank? || params[:password_confirmation].blank?
      flash.now[:alert] = "La password non può essere vuota."
      render :edit, status: :unprocessable_entity
      return
    end

    if params[:password] != params[:password_confirmation]
      flash.now[:alert] = "Le password non coincidono."
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      @user.update!(
        password_reset_token: nil,
        password_reset_sent_at: nil
      )
      redirect_to new_session_path, notice: "La password è stata resettata con successo."
    else
      flash.now[:alert] = "Errore nel reset della password. Assicurati che la password rispetti i requisiti minimi."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    token = params[:token]
    Rails.logger.info "Token ricevuto: #{token}"
    return redirect_to new_password_path, alert: "Token mancante" unless token

    @user = User.find_by(password_reset_token: token)
    Rails.logger.info "Utente trovato: #{@user.inspect}"
    
    unless @user
      Rails.logger.info "Utente non trovato con il token fornito"
      redirect_to new_password_path, alert: "Token scaduto o non valido"
      return
    end

    if @user.password_reset_sent_at < 15.minutes.ago
      Rails.logger.info "Token scaduto"
      Rails.logger.info "Data invio: #{@user.password_reset_sent_at}"
      redirect_to new_password_path, alert: "Token scaduto o non valido"
      return
    end
  end
end

