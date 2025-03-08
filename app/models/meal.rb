class Meal < ApplicationRecord  
  belongs_to :daily_menu

  has_many :mealfood, dependent: :destroy

  validates :daily_menu_id, presence: true
  validates :meal_type, presence: true, inclusion: { in: %w[breakfast lunch dinner snack] }
  validates :calories, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :proteins, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :carbohydrates, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fats, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fiber, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def add_food(food, quantity)
    return false unless food && quantity.positive?
    
    self.calories += food.calories * quantity
    self.proteins += food.proteins * quantity
    self.carbohydrates += food.carbohydrates * quantity
    self.fats += food.fats * quantity
    self.fiber += food.fiber * quantity
    save
  end

  def remove_food(food, quantity = 1)
    return false unless food && quantity.positive?
    
    self.calories -= food.calories * quantity
    self.proteins -= food.proteins * quantity
    self.carbohydrates -= food.carbohydrates * quantity
    self.fats -= food.fats * quantity
    self.fiber -= food.fiber * quantity
    save
  end

  def update_quantity(food, new_quantity)
    return false unless food && new_quantity.positive?
    
    self.calories = food.calories * new_quantity
    self.proteins = food.proteins * new_quantity
    self.carbohydrates = food.carbohydrates * new_quantity
    self.fats = food.fats * new_quantity
    self.fiber = food.fiber * new_quantity
    save
  end

  def nutritional_values
    {
      calories: calories.to_f,
      proteins: proteins.to_f, 
      carbohydrates: carbohydrates.to_f,
      fats: fats.to_f,
      fiber: fiber.to_f
    }
  end
  
end