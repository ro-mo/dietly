class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]
    @token = params[:token]

    mail(
      to: @user.email_address,
      subject: "Reset della tua password"
    )
  end
end
