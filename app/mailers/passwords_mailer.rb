class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]
    @token = params[:token]

    # Usa il metodo 'mail' per inviare l'email
    mail(
      to: @user.email_address,
      subject: "Reset della tua password"
    )
  end
end
