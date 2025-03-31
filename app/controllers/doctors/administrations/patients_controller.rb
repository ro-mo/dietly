class Doctors::Administrations::PatientsController < ApplicationController
  before_action :ensure_doctor
  before_action :set_patient, only: [:edit, :update]

  def index
    @patients = Current.user.patients.order(created_at: :desc)
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to doctors_administrations_patients_management_path, notice: "Dati del paziente aggiornati con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end

  def set_patient
    Rails.logger.info "Cercando paziente con ID: #{params[:id]}"
    Rails.logger.info "Medico corrente: #{Current.user.id}"
    
    # Prima proviamo a trovare il paziente direttamente
    patient = Patient.find_by(id: params[:id])
    
    if patient.nil?
      Rails.logger.error "Paziente non trovato con ID: #{params[:id]}"
      redirect_to doctors_administrations_patients_management_path, alert: "Paziente non trovato."
      return
    end

    # Poi verifichiamo che appartenga al medico corrente
    unless patient.doctor_id == Current.user.id
      Rails.logger.error "Il paziente #{patient.id} non appartiene al medico #{Current.user.id}"
      redirect_to doctors_administrations_patients_management_path, alert: "Non hai i permessi per modificare questo paziente."
      return
    end

    @patient = patient
  end

  def patient_params
    params.require(:patient).permit(
      :first_name,
      :last_name,
      :email_address,
      :phone,
      :fiscal_code
    )
  end
end
