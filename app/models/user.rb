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

  # Validazioni per i campi obbligatori
  validates :first_name, :last_name, :email_address, :phone, presence: true
  validates :email_address, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A\+?[\d\s-]+\z/, message: "deve contenere solo numeri, spazi e trattini" }

  # Validazioni per i campi opzionali
  validates :date_of_birth, presence: true, if: :date_of_birth_changed?
  validates :gender, inclusion: { in: %w[M F O], message: "deve essere M, F o O" }, allow_blank: true
  validates :height, :weight, numericality: { greater_than: 0 }, allow_blank: true
  validates :postal_code, format: { with: /\A\d{5}\z/, message: "deve essere di 5 cifre" }, allow_blank: true

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
    self.verification_status ||= "pending"
  end

  def password_complexity
    return if password.blank?

    errors.add(:password, "deve contenere almeno una lettera maiuscola") unless password =~ /[A-Z]/
    errors.add(:password, "deve contenere almeno una lettera minuscola") unless password =~ /[a-z]/
    errors.add(:password, "deve contenere almeno un numero") unless password =~ /[0-9]/
    errors.add(:password, "deve contenere almeno un carattere speciale (!@#$%^&*()_+-=[]{};':\"\\|,.<>/?") unless password =~ /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/
  end
end
