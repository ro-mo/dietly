class Patients::AdministrationsController < ApplicationController
  before_action :authenticate!
  before_action :ensure_patient

  def diet_routine
    @current_diet = Current.user.diet_plans.active.first
  end

  def doctor_appointments
    @doctor = Current.user.doctor
  end

  private

  def ensure_patient
    unless Current.user.is_a?(Patient)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
