class CalculateNutritionalValuesJob < ApplicationJob
  queue_as :default

  def perform(mealfood_id)
    mealfood = Mealfood.find(mealfood_id)
    
    # Cerca una corrispondenza nel database dei cibi
    food = Food.where("LOWER(name) LIKE ?", "%#{mealfood.ingredient_name.downcase}%").first
    
    if food
      mealfood.food = food
      mealfood.calculate_nutritional_values
    else
      mealfood.calculation_status = 'unmatched'
      mealfood.save
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Mealfood #{mealfood_id} non trovato"
  rescue StandardError => e
    Rails.logger.error "Errore nel job per Mealfood #{mealfood_id}: #{e.message}"
  end
end 