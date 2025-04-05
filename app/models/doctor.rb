class Doctor < User
  has_many :patients, dependent: :nullify
  has_many :appointments, dependent: :destroy
  validates :verification_status, inclusion: { in: %w[pending verified failed], allow_nil: true }

  # La validazione dell'albo_id viene eseguita in background dopo la registrazione
  # validate :albo_id_must_be_valid, on: :update

  # private

  # def albo_id_must_be_valid
  #   verification_service = AlboVerificationService.new
  #   unless verification_service.verify(albo_id)
  #     errors.add(:albo_id, "non risulta registrato nell'Albo Unico Nazionale dei Biologi")
  #   end
  # end
end
