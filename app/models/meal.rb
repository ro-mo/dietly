class Meal < ApplicationRecord
  belongs_to :daily_menu

  has_many :mealfoods, dependent: :destroy
  # Rimosso: has_many :foods, through: :mealfoods

  # Setup for nested forms
  accepts_nested_attributes_for :mealfoods, allow_destroy: true # , reject_if: :all_blank

  validates :meal_type, presence: true, inclusion: { in: %w[colazione snack_mattina pranzo snack_pomeriggio cena] }
  validates :description, presence: true
  validates :time_suggestion, presence: true

  # Callback per loggare i cambiamenti
  after_initialize do |meal|
    Rails.logger.debug "=== MEAL INITIALIZED ==="
    Rails.logger.debug "Meal ID: #{meal.id}"
    Rails.logger.debug "Meal Type: #{meal.meal_type}"
    Rails.logger.debug "Mealfoods count: #{meal.mealfoods.count}"
  end

  after_save do |meal|
    Rails.logger.debug "=== MEAL SAVED ==="
    Rails.logger.debug "Meal ID: #{meal.id}"
    Rails.logger.debug "Meal Type: #{meal.meal_type}"
    Rails.logger.debug "Mealfoods count: #{meal.mealfoods.count}"
    meal.mealfoods.each do |mealfood|
      Rails.logger.debug "  - #{mealfood.ingredient_name} (#{mealfood.quantity} #{mealfood.unit})"
    end
  end

  # Callback per loggare i parametri degli ingredienti ricevuti
  before_validation do
    Rails.logger.debug "=== MEAL BEFORE VALIDATION ==="
    Rails.logger.debug "Meal ID: #{id}"
    Rails.logger.debug "Meal Type: #{meal_type}"
    Rails.logger.debug "Mealfoods count: #{mealfoods.count}"
    mealfoods.each do |mealfood|
      Rails.logger.debug "  - #{mealfood.ingredient_name} (#{mealfood.quantity} #{mealfood.unit})"
    end
  end

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

  # Metodi per calcolare i totali nutrizionali
  def total_calories
    mealfoods.matched.sum(:calories)
  end

  def total_proteins
    mealfoods.matched.sum(:proteins)
  end

  def total_carbohydrates
    mealfoods.matched.sum(:carbohydrates)
  end

  def total_fats
    mealfoods.matched.sum(:fats)
  end

  def total_fiber
    mealfoods.matched.sum(:fiber)
  end

  # Metodo per aggiornare i totali
  def update_nutritional_totals
    update(
      calories: total_calories,
      proteins: total_proteins,
      carbohydrates: total_carbohydrates,
      fats: total_fats,
      fiber: total_fiber
    )
  end

  # I metodi di calcolo nutrizionale basati su Food non sono più validi
  # Commentati o da rimuovere/adattare
  # def total_calories
  #   ...
  # end
  # ... altri metodi total_... e nutritional_values ...

  def formatted_meal_type
    case meal_type
    when "colazione"
      "Colazione"
    when "snack_mattina"
      "Snack mattina"
    when "pranzo"
      "Pranzo"
    when "snack_pomeriggio"
      "Snack pomeriggio"
    when "cena"
      "Cena"
    else
      meal_type.titleize
    end
  end
end
