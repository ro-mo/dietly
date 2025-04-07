class DailyMenu < ApplicationRecord

  belongs_to :diet_plan
  has_many :meals, dependent: :destroy

  # Setup for nested forms
  accepts_nested_attributes_for :meals, allow_destroy: true, reject_if: :all_blank

  validates :diet_plan_id, presence: true
  validates :day_of_week, presence: true, inclusion: { in: 1..7 } # 1 = Monday, 7 = Sunday

  
  def total_calories
    meals.sum do |meal|
      meal.calories.to_f
    end
  end

  # Example method to get day name
  def day_name
    Date::DAYNAMES[day_of_week % 7] # Adjust index based on how day_of_week is stored (0-6 or 1-7)
  end

  

  end