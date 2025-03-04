class Mealfood < ApplicationRecord
  belongs_to :meal
  
  has_many :food, dependent: :destroy

  validates :meal_id, presence: true
  validates :food_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true, inclusion: { in: %w[g kg oz lb] }

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
end
