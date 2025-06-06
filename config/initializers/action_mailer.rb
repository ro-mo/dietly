# Configurazione globale per ActionMailer
# Imposta gli header Content-Type e Content-Transfer-Encoding
ActionMailer::Base.default content_type: "text/html"
ActionMailer::Base.default charset: "UTF-8"

# Aggiungi logging per le email inviate
Rails.application.config.after_initialize do
  ActionMailer::Base.class_eval do
    def deliver_mail(mail)
      Rails.logger.info "Invio email a: #{mail.to}"
      Rails.logger.info "Da: #{mail.from}"
      Rails.logger.info "Configurazione SMTP:"
      Rails.logger.info "- Username: #{ENV['GMAIL_USERNAME']}"
      Rails.logger.info "- Password presente: #{ENV['GMAIL_PASSWORD'].present? ? 'Sì' : 'No'}"
      Rails.logger.info "- From address: #{ActionMailer::Base.default[:from]}"
      super
    end
  end
end
