class Doctors::Administrations::DietsController < ApplicationController
  before_action :ensure_doctor

  def index
    @diet_plans = Current.user.patients
                        .joins(:diet_plans)
                        .select("diet_plans.*, patients.name as patient_name, patients.surname as patient_surname")
                        .order(created_at: :desc)
                        .distinct
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
