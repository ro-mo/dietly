class Patients::RegistrationsController < RegistrationsController
  def new
    @patient = Patient.new
    @doctors = Doctor.all.map { |d| [ "#{d.first_name} #{d.last_name}", d.id ] }
  end

  def create
    @patient = Patient.new(patient_params)
    if @patient.save
      start_new_session_for @patient
      redirect_to after_signup_path, notice: "Welcome! Your account has been created."
    else
      @doctors = Doctor.all.map { |d| [ "#{d.first_name} #{d.last_name}", d.id ] }
      render :new, status: :unprocessable_entity
    end
  end

  private
    def patient_params
      user_params.merge(doctor_id: params[:patient][:doctor_id])
    end

    def after_signup_path
      root_path
    end
end
