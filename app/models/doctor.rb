class Doctor < User
  has_many :patients, dependent: :nullify
  validates :albo_id, presence: true

  # La validazione dell'albo_id viene eseguita in background dopo la registrazione
  # validate :albo_id_must_be_valid, on: :update

  private

  def albo_id_must_be_valid
    verification_service = AlboVerificationService.new
    unless verification_service.verify(albo_id)
      errors.add(:albo_id, "non risulta registrato nell'Albo Unico Nazionale dei Biologi")
    end
  end
end
