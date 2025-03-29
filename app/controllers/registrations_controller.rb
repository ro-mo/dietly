class RegistrationsController < ApplicationController
  layout "authentication"
  allow_unauthenticated_access only: [ :new, :create ]

  def create
    @user = User.new(user_params)

    begin
      if @user.save
        sign_in @user
        redirect_to root_path, notice: "Registrazione completata con successo."
      else
        handle_validation_errors
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique => e
      handle_unique_constraint_error(e)
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(resource_name).permit(:first_name, :last_name, :email_address, :phone, :password, :password_confirmation)
    end

    def resource_name
      controller_path.split("/").first.singularize
    end

    def handle_validation_errors
      if @user.errors[:email_address].include?("has already been taken")
        flash.now[:alert] = "L'indirizzo email è già in uso. Usa un altro indirizzo email."
      elsif @user.errors[:phone].include?("has already been taken")
        flash.now[:alert] = "Il numero di telefono è già in uso. Usa un altro numero di telefono."
      else
        flash.now[:alert] = "Si sono verificati errori durante la registrazione. Controlla i dati inseriti."
      end
    end

    def handle_unique_constraint_error(error)
      if error.message.include?("email_address")
        flash.now[:alert] = "L'indirizzo email è già in uso. Usa un altro indirizzo email."
      elsif error.message.include?("phone")
        flash.now[:alert] = "Il numero di telefono è già in uso. Usa un altro numero di telefono."
      else
        flash.now[:alert] = "Si è verificato un errore durante la registrazione. Riprova più tardi."
      end
    end
end
