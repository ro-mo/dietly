class Patients::AdministrationsController < ApplicationController
  before_action :ensure_patient

  def diet_routine
    begin
      @current_diet = Current.user.diet_plan.active.first
      unless @current_diet
        redirect_to root_path, alert: "Non hai ancora un piano dietetico attivo. Contatta il tuo dottore per ricevere un piano personalizzato."
      end
    rescue ActiveRecord::StatementInvalid
      redirect_to root_path, alert: "Il sistema non è ancora configurato per gestire i piani dietetici. Contatta il tuo dottore per ricevere un piano personalizzato."
    end
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
