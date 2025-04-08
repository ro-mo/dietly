class Patients::AdministrationsController < ApplicationController
  before_action :ensure_patient

  def diet_routine
    begin
      @current_diet = Current.user.diet_plans.active.first
      unless @current_diet
        redirect_to root_path, alert: "Non hai ancora un piano dietetico attivo. Contatta il tuo dottore per ricevere un piano personalizzato."
      end
    rescue ActiveRecord::StatementInvalid
      redirect_to root_path, alert: "Il sistema non è ancora configurato per gestire i piani dietetici. Contatta il tuo dottore per ricevere un piano personalizzato."
    end
  end

  def diet_history
    @diet_plans = Current.user.diet_plans.order(created_at: :desc)
    @current_diet = @diet_plans.active.first
  end

  def diet_details
    @diet_plan = Current.user.diet_plans.find_by(id: params[:id])
    
    unless @diet_plan
      redirect_to patients_administrations_diet_history_path, alert: "Dieta non trovata."
    end
  end

  def my_appointments
    @appointments = Current.user.appointments.includes(:doctor).order(start_time: :desc)
  end

  def doctor_appointments
    @doctor = Current.user.doctor
    unless @doctor
      redirect_to root_path, alert: "Non hai un dottore assegnato."
    end
  end

  private

  def ensure_patient
    unless Current.user.is_a?(Patient)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
