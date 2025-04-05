class AppointmentsController < ApplicationController
  before_action :ensure_authenticated
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]
  before_action :ensure_patient_access, only: [:new, :create]

  def index
    @appointments = if Current.user.is_a?(Doctor)
      Current.user.appointments.includes(:patient)
    else
      Current.user.appointments.includes(:doctor)
    end
  end

  def show
    unless Current.user.is_a?(Doctor) || @appointment.patient == Current.user
      redirect_to appointments_path, alert: "Non hai i permessi per visualizzare questo appuntamento"
    end
  end

  def new
    @appointment = Appointment.new
    @doctors = Doctor.all
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.patient = Current.user
    @appointment.status = 'pending'
    
    # Imposta automaticamente l'orario di fine 20 minuti dopo l'orario di inizio
    if @appointment.start_time.present?
      @appointment.end_time = @appointment.start_time + 20.minutes
    end

    if @appointment.save
      redirect_to appointments_path, notice: 'Appuntamento richiesto con successo'
    else
      @doctors = Doctor.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless Current.user.is_a?(Doctor) || @appointment.patient == Current.user
      redirect_to appointments_path, alert: "Non hai i permessi per modificare questo appuntamento"
    end
  end

  def update
    # Imposta automaticamente l'orario di fine 20 minuti dopo l'orario di inizio
    if params[:appointment][:start_time].present?
      params[:appointment][:end_time] = Time.parse(params[:appointment][:start_time]) + 20.minutes
    end
    
    if @appointment.update(appointment_params)
      redirect_to appointments_path, notice: 'Appuntamento aggiornato con successo'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @appointment.destroy
      redirect_to appointments_path, notice: 'Appuntamento cancellato con successo'
    else
      redirect_to appointments_path, alert: 'Errore durante la cancellazione dell\'appuntamento'
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:doctor_id, :start_time, :notes)
  end

  def ensure_patient_access
    unless Current.user.is_a?(Patient)
      redirect_to appointments_path, alert: "Solo i pazienti possono prenotare appuntamenti"
    end
  end

  def ensure_authenticated
    unless Current.user
      redirect_to sign_in_path, alert: "Devi essere autenticato per accedere a questa pagina"
    end
  end
end 