# Migrazione del Database da SQLite3 a MySQL

## Prerequisiti
- MySQL installato sul sistema
- Accesso come root a MySQL
- Backup del database SQLite3 esistente

## Passaggi della Migrazione

### 1. Configurazione di MySQL
1. Installare MySQL (se non già installato):
   ```bash
   brew install mysql
   ```

2. Avviare il servizio MySQL:
   ```bash
   brew services start mysql
   ```

### 2. Modifica della Configurazione del Database
1. Modificare il file `config/database.yml`:
   ```yaml
   default: &default
     adapter: mysql2
     encoding: utf8mb4
     pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
     username: root
     password: 
     host: localhost
     socket: /tmp/mysql.sock
   ```

2. Aggiornare il `Gemfile`:
   ```ruby
   # Rimuovere o commentare la gemma sqlite3
   # gem "sqlite3", "~> 1.4"
   
   # Aggiungere la gemma mysql2
   gem "mysql2", "~> 0.5.4"
   ```

3. Installare le nuove dipendenze:
   ```bash
   bundle install
   ```

### 3. Creazione del Nuovo Database
1. Creare i database MySQL:
   ```bash
   rails db:create
   ```

2. Eseguire le migrazioni:
   ```bash
   rails db:migrate
   ```

### 4. Trasferimento dei Dati
1. Creare un task personalizzato per il trasferimento (`lib/tasks/transfer_data.rake`):
   ```ruby
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
           encrypted_password: BCrypt::Password.create('password123'),
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
     end
   end
   ```

2. Eseguire il task di trasferimento:
   ```bash
   rails db:transfer_data
   ```

### 5. Verifica della Migrazione
1. Verificare che tutti i dati siano stati trasferiti correttamente
2. Testare l'accesso degli utenti con la password temporanea 'password123'
3. Verificare che tutte le funzionalità dell'applicazione funzionino correttamente

## Note Importanti
- Tutti gli utenti sono stati trasferiti con una password temporanea ('password123')
- Gli utenti dovranno resettare la loro password al prossimo accesso
- Il vecchio database SQLite3 è stato mantenuto come backup
- Le sessioni esistenti sono state trasferite con nuovi ID di sessione

## Risoluzione dei Problemi
Se si verificano problemi durante la migrazione:
1. Verificare che MySQL sia in esecuzione
2. Controllare le credenziali di accesso a MySQL
3. Verificare i permessi del database
4. Controllare i log di MySQL per eventuali errori 