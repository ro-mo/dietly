class AddDetailsToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :start_time, :datetime
    add_column :appointments, :end_time, :datetime
    add_column :appointments, :status, :string
    add_column :appointments, :notes, :text
  end
end
