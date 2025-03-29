class Doctors::DashboardController < ApplicationController
  before_action :authenticate!
  before_action :ensure_doctor

  def index
    @doctor = Current.user
    @upcoming_appointments = @doctor.appointments.upcoming.order(date: :asc).limit(5)
    @recent_patients = @doctor.patients.order(created_at: :desc).limit(5)
    @recent_prescriptions = @doctor.prescriptions.order(created_at: :desc).limit(5)
    @total_patients = @doctor.patients.count
    @total_appointments = @doctor.appointments.count
    @total_prescriptions = @doctor.prescriptions.count
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
