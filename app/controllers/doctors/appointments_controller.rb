module Doctors
  class AppointmentsController < ApplicationController
    before_action :ensure_authenticated
    before_action :set_appointment, only: [:show, :edit, :update, :destroy]
    before_action :ensure_doctor_access

    def index
      # Qui il contesto è sempre il dottore
      @appointments = Current.user.appointments.includes(:patient).order(start_time: :desc)
    end

    def show
      # set_appointment garantisce che l'appuntamento appartenga al dottore
    end

    def new
      @appointment = Appointment.new
      @patients = Current.user.patients
    end

    def create
      @appointment = Current.user.appointments.new(appointment_params)
      
      if @appointment.start_time.present?
        @appointment.end_time = @appointment.start_time + 20.minutes
      end

      if @appointment.save
        # Usiamo il percorso corretto namespacizzato
        redirect_to doctors_appointments_path, notice: 'Appuntamento creato con successo'
      else
        @patients = Current.user.patients
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # set_appointment garantisce che l'appuntamento appartenga al dottore
      @patients = Current.user.patients
    end

    def update
      # set_appointment garantisce che l'appuntamento appartenga al dottore
      # Logica per end_time
      start_time_param = params[:appointment][:start_time]
      if start_time_param.present? && start_time_param != @appointment.start_time&.strftime('%Y-%m-%dT%H:%M')
        begin
          new_start_time = Time.zone.parse(start_time_param)
          params[:appointment][:end_time] = new_start_time + 20.minutes if new_start_time
        rescue ArgumentError
          # Gestisci l'errore se il formato della data non è valido
          @patients = Current.user.patients
          @appointment.errors.add(:start_time, :invalid, message: "Formato data non valido")
          return render :edit, status: :unprocessable_entity
        end
      elsif start_time_param.blank?
        params[:appointment][:end_time] = nil
      elsif @appointment.start_time.present?
        # Mantiene la durata se start_time non cambia esplicitamente ma era già presente
        params[:appointment][:end_time] = @appointment.start_time + 20.minutes
      end

      if @appointment.update(appointment_params)
        redirect_to doctors_appointments_path, notice: 'Appuntamento aggiornato con successo'
      else
        @patients = Current.user.patients
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # set_appointment garantisce che l'appuntamento appartenga al dottore
      if @appointment.destroy
        redirect_to doctors_appointments_path, notice: 'Appuntamento cancellato con successo'
      else
        # Usiamo il percorso corretto namespacizzato per il redirect in caso di errore
        redirect_to doctors_appointments_path, alert: 'Errore durante la cancellazione dell\'appuntamento'
      end
    end

    private

    def set_appointment
      # Il contesto è sempre il dottore, semplifichiamo la ricerca
      @appointment = Current.user.appointments.find_by(id: params[:id])
      redirect_to doctors_appointments_path, alert: "Appuntamento non trovato." unless @appointment
    end

    def appointment_params
      params.require(:appointment).permit(:patient_id, :start_time, :notes)
    end

    def ensure_doctor_access
      # Questo metodo è chiamato da ApplicationController o garantisce che Current.user sia un dottore
      unless Current.user.is_a?(Doctor)
        redirect_to root_path, alert: "Non hai i permessi per eseguire questa azione."
      end
    end

    # ensure_authenticated è gestito da ApplicationController
    # Ripristiniamo la definizione nel caso non sia in ApplicationController
    def ensure_authenticated
      unless Current.user
        redirect_to new_session_path, alert: "Devi essere autenticato per accedere a questa pagina"
      end
    end
  end
end 