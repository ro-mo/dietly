namespace :email do
  desc "Test di invio email SMTP"
  task test: :environment do
    puts "Preparazione per l'invio di un'email di test..."
    puts "Username SMTP: #{ENV['GMAIL_USERNAME']}"
    puts "Password SMTP: #{ENV['GMAIL_PASSWORD'] ? 'impostata (nascosta)' : 'non impostata'}"

    begin
      # Crea un messaggio di prova
      mail = ActionMailer::Base.mail(
        from: "noreply@dietly.com",
        to: ENV["TEST_EMAIL"] || ENV["GMAIL_USERNAME"],
        subject: "Test SMTP da Dietly",
        body: "Questa \u00E8 una email di test per verificare la configurazione SMTP."
      )

      # Invia il messaggio
      puts "Tentativo di invio email..."
      result = mail.deliver_now
      puts "Email inviata con successo!"
      puts "Risultato: #{result.inspect}"
    rescue => e
      puts "ERRORE durante l'invio dell'email: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end
