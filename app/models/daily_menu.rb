class DailyMenu < ApplicationRecord

  belongs_to :diet_plan
  has_many :meal, dependent: :destroy

  validates :diet_plan_id, presence: true
  validates :day_of_week, presence: true, inclusion: { in: 1..7 }

  
    def total_calories
      meals.sum do |meal|
        meal.calories.to_f
      end
    end

  

  end