class PasswordsMailer < ApplicationMailer
  def send_reset_email
    @user = params[:user]
    @token = params[:token]

    # Usa il metodo 'mail' per inviare l'email
    mail(
      to: @user.email,
      subject: "Reset della tua password"
    )
  end
end
