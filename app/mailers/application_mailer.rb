class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['GMAIL_USERNAME']}@gmail.com"
  layout "mailer"
end
