class Patients::ProfilesController < ApplicationController
  before_action :authenticate!
  before_action :ensure_patient
  before_action :set_patient

  def show
  end

  def edit
  end

  def update
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
      :name,
      :surname,
      :email,
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
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
