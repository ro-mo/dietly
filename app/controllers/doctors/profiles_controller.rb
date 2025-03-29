class Doctors::ProfilesController < ApplicationController
  before_action :authenticate!
  before_action :ensure_doctor
  before_action :set_doctor

  def show
  end

  def edit
  end

  def update
    if @doctor.update(doctor_params)
      redirect_to doctors_profile_path, notice: "Profilo aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_doctor
    @doctor = Current.user
  end

  def doctor_params
    params.require(:doctor).permit(
      :name,
      :surname,
      :email,
      :phone,
      :specialization,
      :bio,
      :address,
      :city,
      :postal_code
    )
  end

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
