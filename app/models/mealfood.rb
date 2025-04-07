class Mealfood < ApplicationRecord
  belongs_to :meal
  belongs_to :food, optional: true

  validates :meal_id, presence: true
  validates :ingredient_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :calculation_status, inclusion: { in: %w[pending matched unmatched error] }

  # Scopes per filtrare per stato di calcolo
  scope :pending_calculation, -> { where(calculation_status: 'pending') }
  scope :matched, -> { where(calculation_status: 'matched') }
  scope :unmatched, -> { where(calculation_status: 'unmatched') }
  scope :error, -> { where(calculation_status: 'error') }

  # Delegate food attributes for easier access in views/forms if needed
  # delegate :name, :category, :calories_per_100g, to: :food, prefix: true

  # Potremmo aggiungere metodi per la conversione di unità se necessario

  def convert_unit(new_unit)
    return false unless new_unit.present? && %w[g kg oz lb].include?(new_unit)
    
    # Conversione da unità corrente a grammi
    grams = case unit
            when 'g'
              quantity 
            when 'kg'
              quantity * 1000
            when 'oz'
              quantity * 28.35
            when 'lb'
              quantity * 453.59
            end
    
    # Conversione da grammi alla nuova unità
    new_quantity = case new_unit
                  when 'g'
                    grams
                  when 'kg'
                    grams / 1000.0
                  when 'oz'
                    grams / 28.35
                  when 'lb'
                    grams / 453.59
                  end

    self.quantity = new_quantity.round(2)
    self.unit = new_unit
    save
  end

  # Metodo per calcolare i valori nutrizionali
  def calculate_nutritional_values
    return unless food.present?

    # Calcola i valori nutrizionali in base alla quantità
    self.calories = (food.calories * quantity / 100).round(2)
    self.proteins = (food.proteins * quantity / 100).round(2)
    self.carbohydrates = (food.carbohydrates * quantity / 100).round(2)
    self.fats = (food.fats * quantity / 100).round(2)
    self.fiber = (food.fiber * quantity / 100).round(2)
    self.calculation_status = 'matched'
    save
  rescue StandardError => e
    self.calculation_status = 'error'
    save
    Rails.logger.error "Errore nel calcolo dei valori nutrizionali per Mealfood #{id}: #{e.message}"
  end
end
