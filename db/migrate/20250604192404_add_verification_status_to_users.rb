class AddVerificationStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :verification_status, :string, default: "pending", null: false
    add_index :users, :verification_status
  end
end
