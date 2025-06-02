class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Validazioni per la password
  validates :password, length: { 
    minimum: 6, 
    maximum: 12,
    too_short: "deve essere di almeno %{count} caratteri",
    too_long: "non può essere più lunga di %{count} caratteri"
  }, if: -> { new_record? || !password.nil? }

  validate :password_complexity, if: -> { new_record? || !password.nil? }

  validates :verification_status, inclusion: { in: %w[pending verified rejected] }

  # Validazioni per i campi di reset password
  validates :password_reset_token, uniqueness: true, allow_nil: true
  validates :password_reset_attempts, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_default_verification_status, on: :create

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def name
    full_name
  end

  def can_request_password_reset?
    return false if password_reset_locked_until&.future?
    password_reset_attempts.to_i < 3
  end

  def reset_password_token!
    return false unless can_request_password_reset?

    update!(
      password_reset_token: SecureRandom.hex(20),
      password_reset_sent_at: Time.current,
      password_reset_attempts: password_reset_attempts.to_i + 1
    )
  end

  def clear_password_reset!
    update!(
      password_reset_token: nil,
      password_reset_sent_at: nil,
      password_reset_attempts: 0,
      password_reset_locked_until: nil
    )
  end

  private

  def set_default_verification_status
    self.verification_status ||= 'pending'
  end

  def password_complexity
    return if password.blank?

    errors.add(:password, "deve contenere almeno una lettera maiuscola") unless password =~ /[A-Z]/
    errors.add(:password, "deve contenere almeno una lettera minuscola") unless password =~ /[a-z]/
    errors.add(:password, "deve contenere almeno un numero") unless password =~ /[0-9]/
    errors.add(:password, "deve contenere almeno un carattere speciale (!@#$%^&*()_+-=[]{};':\"\\|,.<>/?") unless password =~ /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/
  end
end
