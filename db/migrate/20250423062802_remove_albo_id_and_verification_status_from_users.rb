class RemoveAlboIdAndVerificationStatusFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :albo_id, :string
    remove_column :users, :verification_status, :string
  end
end
