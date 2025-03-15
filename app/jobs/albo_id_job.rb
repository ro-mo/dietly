class VerifyAlboIdJob < ApplicationJob
  queue_as :default

  def perform(doctor_id)
    doctor = Doctor.find(doctor_id)
    verification_service = AlboVerificationService.new
    result = verification_service.verify(doctor.albo_id)

    doctor.update(verification_status: result ? "verified" : "failed")
    # Invia notifiche appropriate
    if result
      # Qui puoi aggiungere codice per inviare una notifica di successo
      Rails.logger.info "Albo ID #{doctor.albo_id} verificato con successo per il medico #{doctor.id}"
    else
      # Qui puoi aggiungere codice per inviare una notifica di fallimento
      Rails.logger.warn "Verifica fallita per Albo ID #{doctor.albo_id} del medico #{doctor.id}"
    end
  end
end
