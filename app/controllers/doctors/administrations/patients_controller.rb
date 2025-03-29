class Doctors::Administrations::PatientsController < ApplicationController
  before_action :ensure_doctor

  def index
    @patients = Current.user.patients.order(created_at: :desc)
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
