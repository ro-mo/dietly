class AddPatientDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :doctor, foreign_key: { to_table: :users }  end
end
