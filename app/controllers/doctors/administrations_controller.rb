class Doctors::AdministrationsController < ApplicationController
  before_action :ensure_doctor

  def patients_management
    begin
      @patients = Current.user.patients.order(created_at: :desc)
      if @patients.empty?
        flash.now[:notice] = "Non hai ancora nessun paziente assegnato."
      end
    rescue ActiveRecord::StatementInvalid => e
      flash.now[:alert] = "Si è verificato un errore nel caricamento dei pazienti."
      Rails.logger.error("Errore nel caricamento dei pazienti: #{e.message}")
    end
  end

  def diets_management
    begin
      @diet_plans = Current.user.patients
                            .joins(:diet_plans)
                            .select("diet_plans.*, patients.name as patient_name, patients.surname as patient_surname")
                            .order(created_at: :desc)
                            .distinct

      if @diet_plans.empty?
        flash.now[:notice] = "Non ci sono piani dietetici attivi."
      end
    rescue ActiveRecord::StatementInvalid => e
      flash.now[:alert] = "Si è verificato un errore nel caricamento dei piani dietetici."
      Rails.logger.error("Errore nel caricamento dei piani dietetici: #{e.message}")
    end
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end
end
