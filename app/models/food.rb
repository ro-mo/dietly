class Food < ApplicationRecord
  has_many :mealfood, dependent: :destroy

  validates :name, presence: true
  validates :category, presence: true
  validates :calories_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  

  # La funzione similar_foods() trova cibi simili basandosi sulla categoria e sulle calorie
  # Esempio di implementazione:
  # def similar_foods
  #   Food.where(category: self.category)
  #       .where(calories_per_100g: (self.calories_per_100g * 0.8)..(self.calories_per_100g * 1.2))
  #       .where.not(id: self.id)
  # end
  # VEDI IMPLEMENTAZIONE
end
