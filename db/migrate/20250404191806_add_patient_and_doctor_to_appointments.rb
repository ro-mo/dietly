class AddPatientAndDoctorToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :patient_id, :integer
    add_column :appointments, :doctor_id, :integer
  end
end
