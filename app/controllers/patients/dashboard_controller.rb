class Patients::DashboardController < ApplicationController
  before_action :authenticate!
  before_action :ensure_patient

  def index
    @patient = Current.user
    @current_diet = @patient.diet_plans.active.first
    @upcoming_appointments = @patient.appointments.upcoming.order(date: :asc).limit(5)
    @recent_prescriptions = @patient.prescriptions.order(created_at: :desc).limit(5)
    @doctor = @patient.doctor
    @progress = @patient.progress
    @daily_calories = @current_diet&.daily_calories || 0
    @weekly_goals = @current_diet&.weekly_goals || []
  end

  private

  def ensure_patient
    unless Current.user.is_a?(Patient)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
