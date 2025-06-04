class Patients::ProfilesController < ApplicationController
  include Authentication
  before_action :set_patient
  before_action :ensure_patient

  def show
  end

  def edit
  end

  def update
    params[:patient].delete(:verification_status) if params[:patient].present?

    if @patient.update(patient_params)
      redirect_to patients_profile_path, notice: "Profilo aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = Current.user
  end

  def patient_params
    params.require(:patient).permit(
      :first_name,
      :last_name,
      :email_address,
      :phone,
      :date_of_birth,
      :gender,
      :height,
      :weight,
      :address,
      :city,
      :postal_code
    )
  end

  def ensure_patient
    unless Current.user.is_a?(Patient)
      redirect_to root_path, alert: "Accesso non autorizzato."
    end
  end
end
