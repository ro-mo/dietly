class DietPlan < ApplicationRecord
  belongs_to :patient, class_name: 'User' # Assuming Patient inherits from User
  belongs_to :doctor, class_name: 'User'  # Assuming Doctor inherits from User
  has_many :daily_menus, dependent: :destroy
  has_many :meals, through: :daily_menus

  # Setup for nested forms
  accepts_nested_attributes_for :daily_menus, allow_destroy: true, reject_if: :all_blank

  validates :patient_id, presence: true
  validates :doctor_id, presence: true
  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :active, inclusion: { in: [ true, false ] }
  validate :end_date_after_start_date

  scope :active, -> { where(active: true) }

  def self.set_inactive_expired
    where("end_date < ?", Date.current).update_all(active: false)
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
