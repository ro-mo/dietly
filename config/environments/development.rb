require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Ricarica il codice senza riavviare il server
  config.enable_reloading = true

  # Non eseguire eager load del codice all'avvio
  config.eager_load = false

  # Mostra i report completi degli errori
  config.consider_all_requests_local = true

  # Abilita il server timing
  config.server_timing = true

  # Configurazione della cache
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  config.cache_store = :memory_store

  # Memorizza i file caricati in locale
  config.active_storage.service = :local

  # Configurazione del mailer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  
  # Configurazione SMTP per SendGrid
  config.action_mailer.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: 587,
    domain: 'dietly.com',
    user_name: 'apikey',
    password: ENV['SENDGRID_API_KEY'],
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Log delle deprecazioni
  config.active_support.deprecation = :log

  # Segnala errori se ci sono migrazioni pendenti
  config.active_record.migration_error = :page_load

  # Log delle query del database
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true

  # Log dei job di background
  config.active_job.verbose_enqueue_logs = true

  # Mostra nomi dei file nei template renderizzati
  config.action_view.annotate_rendered_view_with_filenames = true

  # Segnala errori per callback mancanti nei controller
  config.action_controller.raise_on_missing_callback_actions = true
end
