# Configurazione globale per ActionMailer
ActionMailer::Base.default from: "Dietly <dietlyrecover2025@gmail.com>"

# Imposta gli header Content-Type e Content-Transfer-Encoding
ActionMailer::Base.default content_type: "text/html"
ActionMailer::Base.default charset: "UTF-8"

# Aggiungi logging per le email inviate
Rails.application.config.after_initialize do
  ActionMailer::Base.class_eval do
    def deliver_mail(mail)
      Rails.logger.info "Invio email a: #{mail.to}"
      super
    end
  end
end
