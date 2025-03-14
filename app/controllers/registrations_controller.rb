class RegistrationsController < ApplicationController
  layout "authentication"
  allow_unauthenticated_access only: [ :new, :create ]

  private
    def user_params
      params.require(resource_name).permit(:first_name, :last_name, :email_address, :phone, :password, :password_confirmation, :albo_id)
    end

    def resource_name
      controller_path.split("/").first.singularize
    end
end
