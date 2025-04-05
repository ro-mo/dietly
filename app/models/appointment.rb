class Appointment < ApplicationRecord
  belongs_to :patient, class_name: 'Patient', foreign_key: 'patient_id', primary_key: 'id'
  belongs_to :doctor, class_name: 'Doctor', foreign_key: 'doctor_id', primary_key: 'id'

  validates :start_time, presence: true
  validates :end_time, presence: true 
  
  validate :end_time_after_start_time
  validate :no_overlapping_appointments

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "deve essere successiva all'orario di inizio")
    end
  end

  def no_overlapping_appointments
    return if start_time.blank? || end_time.blank?

    overlapping = Appointment.where(doctor: doctor)
                           .where.not(id: id)
                           .where('start_time < ? AND end_time > ?', end_time, start_time)
                           .exists?

    if overlapping
      errors.add(:base, "esiste già un appuntamento in questo orario")
    end
  end
end
