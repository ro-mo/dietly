class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Validazioni per la password
  #validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  #validates :password, format: { 
  #  with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/,
  #  message: "deve contenere almeno 8 caratteri, una lettera maiuscola, una minuscola, un numero e un carattere speciale"
  #}, if: -> { new_record? || !password.nil? }

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
end
