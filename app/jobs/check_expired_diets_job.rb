class CheckExpiredDietsJob < ApplicationJob
  queue_as :default

  def perform
    DietPlan.set_inactive_expired
  end
end
