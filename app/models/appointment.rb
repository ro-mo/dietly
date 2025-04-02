# app/models/appointment.rb
class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient
  
  validates :scheduled_at, presence: true
  validates :status, presence: true
  
  # Alternative to enum using constants
  STATUS_PENDING = 0
  STATUS_CONFIRMED = 1
  STATUS_COMPLETED = 2
  STATUS_CANCELLED = 3
  
  # Collection of valid statuses
  STATUSES = {
    pending: STATUS_PENDING,
    confirmed: STATUS_CONFIRMED,
    completed: STATUS_COMPLETED,
    cancelled: STATUS_CANCELLED
  }.freeze
  
  # Validation to ensure status is within allowed values
  validates :status, inclusion: { in: STATUSES.values }
  
  # Instance methods for status checks
  def pending?
    status == STATUS_PENDING
  end
  
  def confirmed?
    status == STATUS_CONFIRMED
  end
  
  def completed?
    status == STATUS_COMPLETED
  end
  
  def cancelled?
    status == STATUS_CANCELLED
  end
  
  # Status setter with symbol support
  def status=(value)
    if value.is_a?(Symbol) && STATUSES.key?(value)
      super(STATUSES[value])
    else
      super
    end
  end
  
  # Status getter with symbol conversion
  def status_name
    STATUSES.key(status)
  end
  
  # Scope methods (formerly provided by enum)
  def self.pending
    where(status: STATUS_PENDING)
  end
  
  def self.confirmed
    where(status: STATUS_CONFIRMED)
  end
  
  def self.completed
    where(status: STATUS_COMPLETED)
  end
  
  def self.cancelled
    where(status: STATUS_CANCELLED)
  end
  
  def upcoming?
    scheduled_at > Time.current
  end
end