class Doctors::AdministrationsController < ApplicationController
  before_action :authenticate!
  before_action :ensure_doctor

  def patients_management
    @patients = Current.user.patients
  end

  def diets_management
    @diet_plans = Current.user.patients.joins(:diet_plans).distinct
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
