namespace :db do
  desc "Transfer data from SQLite to MySQL"
  task transfer_data: :environment do
    # Configurazione temporanea per SQLite
    sqlite_config = {
      adapter: 'sqlite3',
      database: 'storage/development.sqlite3'
    }

    # Connessione al database SQLite
    sqlite_db = SQLite3::Database.new(sqlite_config[:database])
    sqlite_db.results_as_hash = true

    # Trasferimento degli utenti
    puts "Trasferimento utenti..."
    sqlite_db.execute("SELECT * FROM users") do |row|
      user = User.new(
        email: row['email_address'],
        encrypted_password: BCrypt::Password.create('password123'), # Password temporanea crittografata
        first_name: row['first_name'],
        last_name: row['last_name'],
        phone: row['phone'],
        created_at: row['created_at'],
        updated_at: row['updated_at']
      )
      user.save(validate: false)
      puts "Utente #{row['email_address']} trasferito con successo"
    end

    # Trasferimento delle sessioni
    puts "Trasferimento sessioni..."
    sqlite_db.execute("SELECT * FROM sessions") do |row|
      Session.create!(
        user_id: row['user_id'],
        session_id: SecureRandom.hex(16),
        data: row['data'],
        created_at: row['created_at'],
        updated_at: row['updated_at']
      )
      puts "Sessione per l'utente #{row['user_id']} trasferita con successo"
    end

    puts "Trasferimento completato con successo!"
  end
end 