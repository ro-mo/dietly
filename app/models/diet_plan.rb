class DietPlan < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor
  has_many :daily_menus, dependent: :destroy
  has_many :meals, through: :daily_menus

  validates :patient_id, presence: true
  validates :doctor_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  def self.active
    where(active: true)
  end

  def self.set_inactive_expired
    where("end_date < ?", Date.current).update_all(active: false)
  end
end
