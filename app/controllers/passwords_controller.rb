class PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[new create edit update]
  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    
    if user
      # Genera un nuovo token di reset nel formato corretto
      expiration_time = 15.minutes.from_now
      token_data = {
        data: [user.id, SecureRandom.urlsafe_base64],
        exp: expiration_time.to_i,  # Converti in timestamp Unix
        pur: "User\npassword_reset\n900"
      }
      user.password_reset_token = JWT.encode(token_data, Rails.application.credentials.secret_key_base)
      user.password_reset_sent_at = expiration_time
      
      user.save!
      
      PasswordsMailer.with(user: user, token: user.password_reset_token).reset.deliver_now
    end

    redirect_to new_session_path, notice: "Istruzioni per il reset della password inviate (se l'utente con quella email esiste)."
  end

  def edit
    @user = User.find_by!(password_reset_token: params[:token])
    
    # Commento il controllo dei tentativi
    # if @user.password_reset_locked_until && @user.password_reset_locked_until > Time.current
    #   redirect_to new_session_path, alert: "Troppi tentativi. Riprova tra #{distance_of_time_in_words(@user.password_reset_locked_until, Time.current)}."
    #   return
    # end
  end

  def update
    @user = User.find_by!(password_reset_token: params[:token])
    
    # Commento il controllo dei tentativi
    # if @user.password_reset_locked_until && @user.password_reset_locked_until > Time.current
    #   redirect_to new_session_path, alert: "Troppi tentativi. Riprova tra #{distance_of_time_in_words(@user.password_reset_locked_until, Time.current)}."
    #   return
    # end

    if @user.password_reset_sent_at && @user.password_reset_sent_at < Time.current
      redirect_to new_session_path, alert: "Il link di reset è scaduto. Richiedi un nuovo link."
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      @user.password_reset_token = nil
      @user.password_reset_sent_at = nil
      @user.save!
      
      redirect_to new_session_path, notice: "Password aggiornata con successo."
    else
      # Commento l'incremento dei tentativi
      # @user.increment!(:password_reset_attempts)
      # if @user.password_reset_attempts >= 3
      #   @user.update(password_reset_locked_until: 1.hour.from_now)
      # end
      
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

