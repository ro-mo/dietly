class DietPlan < ApplicationRecord
  belongs_to :patient, class_name: "User" # Assuming Patient inherits from User
  belongs_to :doctor, class_name: "User"  # Assuming Doctor inherits from User
  has_many :daily_menus, dependent: :destroy
  has_many :meals, through: :daily_menus

  # Setup for nested forms
  accepts_nested_attributes_for :daily_menus, allow_destroy: true, reject_if: :all_blank

  validates :patient_id, presence: true
  validates :doctor_id, presence: true
  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :active, inclusion: { in: [ true, false ] }
  validate :end_date_after_start_date

  scope :active, -> { where(active: true) }

  # Callback per controllare automaticamente le diete scadute
  after_find :check_expiration

  def self.set_inactive_expired
    where("end_date < ?", Date.current).update_all(active: false)
  end

  def shopping_list
    # Inizializza un hash per tenere traccia delle quantità totali per ingrediente
    shopping_list = {}

    # Itera attraverso tutti i pasti di tutti i giorni
    daily_menus.each do |daily_menu|
      daily_menu.meals.each do |meal|
        meal.mealfoods.each do |mealfood|
          ingredient_name = mealfood.ingredient_name.downcase.strip
          quantity = mealfood.quantity.to_f
          unit = mealfood.unit.downcase

          # Converti tutto in grammi per la somma
          quantity_in_grams = case unit
          when "g"
              quantity
          when "kg"
              quantity * 1000
          when "oz"
              quantity * 28.35
          when "lb"
              quantity * 453.59
          else
              quantity # mantieni l'unità originale se non riconosciuta
          end

          # Aggiorna o inizializza l'ingrediente nella lista della spesa
          if shopping_list[ingredient_name]
            shopping_list[ingredient_name][:quantity] += quantity_in_grams
          else
            shopping_list[ingredient_name] = {
              quantity: quantity_in_grams,
              original_unit: unit
            }
          end
        end
      end
    end

    # Converti le quantità in unità appropriate (g o kg)
    shopping_list.transform_values! do |data|
      quantity = data[:quantity]
      if quantity >= 1000
        { quantity: (quantity / 1000.0).round(2), unit: "kg" }
      else
        { quantity: quantity.round(2), unit: "g" }
      end
    end

    # Ordina la lista alfabeticamente per nome ingrediente
    shopping_list.sort.to_h
  end

  private

  def check_expiration
    if active? && end_date < Date.current
      update_column(:active, false)
    end
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "deve essere successiva alla data di inizio")
    end
  end
end
