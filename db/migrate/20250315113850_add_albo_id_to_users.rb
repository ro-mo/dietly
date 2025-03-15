class AddAlboIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :albo_id, :string
    add_column :users, :verification_status, :string
  end
end
