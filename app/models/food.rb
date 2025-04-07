class Food < ApplicationRecord
  # Rimosso: has_many :mealfoods, dependent: :destroy
  # Rimosso: has_many :meals, through: :mealfoods

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :category, presence: true
  validates :calories_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :proteins_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :carbohydrates_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fats_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fiber_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  

  # La funzione similar_foods() trova cibi simili basandosi sulla categoria e sulle calorie
  # Esempio di implementazione:
  # def similar_foods
  #   Food.where(category: self.category)
  #       .where(calories_per_100g: (self.calories_per_100g * 0.8)..(self.calories_per_100g * 1.2))
  #       .where.not(id: self.id)
  # end
  # VEDI IMPLEMENTAZIONE
end
