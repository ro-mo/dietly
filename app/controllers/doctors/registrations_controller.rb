class Doctors::RegistrationsController < RegistrationsController
  def new
    @doctor = Doctor.new
  end

  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      start_new_session_for @doctor
      redirect_to after_signup_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def doctor_params
      user_params
    end

    def after_signup_path
      root_path
    end
end
