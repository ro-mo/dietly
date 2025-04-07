class AddVerificationStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :verification_status)
      add_column :users, :verification_status, :string
    end
  end
end
