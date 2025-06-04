class HomeController < ApplicationController
  allow_unauthenticated_access only: [ :show ]
  def show
    if authenticated?
      if Current.user.is_a?(Patient)
        @current_diet = Current.user.diet_plans
          .where("start_date <= ? AND end_date >= ?", Date.today, Date.today)
          .first
      else
        @upcoming_appointments = Current.user.appointments
          .where("start_time >= ?", Time.current)
          .order(start_time: :asc)
          .limit(3)
      end
    end
  end
end
