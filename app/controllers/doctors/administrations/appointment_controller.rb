module Doctors
  module Administrations
    class AppointmentController < ApplicationController
      before_action :require_doctor_authentication
      
      def index
        # Get all appointments for the current doctor
        @appointments = Current.user.appointments.order(date: :desc)
        
        # Split into upcoming and past appointments in the controller
        @upcoming_appointments = @appointments.where("date > ?", Time.current).order(date: :asc)
        @past_appointments = @appointments.where("date <= ?", Time.current).order(date: :desc)
      end
      
      private
      
      def require_doctor_authentication
        redirect_to new_session_path unless authenticated? && Current.user.is_a?(Doctor)
      end
    end
  end
end
