class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]
    @token = params[:token]

    # Usa il metodo 'mail' per inviare l'email
    if Rails.env.development?
      mail(
        to: @user.email_address,
        subject: "Reset della tua password"
      ).deliver_now
    else
      mail(
        to: @user.email_address,
        subject: "Reset della tua password"
      ).deliver_later
    end
  end

  default from: "noreply@dietly.com"
end
