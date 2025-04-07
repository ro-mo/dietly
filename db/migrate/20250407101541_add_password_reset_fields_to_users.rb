class AddPasswordResetFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Aggiunge il token di reset password con indice per ricerche veloci
    add_column :users, :password_reset_token, :string
    add_index :users, :password_reset_token, unique: true

    # Aggiunge la data di scadenza del token
    add_column :users, :password_reset_sent_at, :datetime
    add_index :users, :password_reset_sent_at

    # Aggiunge il contatore dei tentativi di reset con valore predefinito 0
    add_column :users, :password_reset_attempts, :integer, default: 0

    # Aggiunge la data fino a cui il reset è bloccato
    add_column :users, :password_reset_locked_until, :datetime
  end
end
