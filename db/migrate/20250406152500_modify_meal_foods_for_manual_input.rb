class ModifyMealFoodsForManualInput < ActiveRecord::Migration[7.1]
  def change
    # Rimuove la chiave esterna e l'indice associato a food_id
    remove_reference :mealfoods, :food, foreign_key: true, index: true

    # Aggiunge la nuova colonna per il nome dell'ingrediente
    add_column :mealfoods, :ingredient_name, :string

    # Rende food_id facoltativo
    change_column_null :mealfoods, :food_id, true

    # Aggiunge le colonne per i valori nutrizionali calcolati
    add_column :mealfoods, :calories, :decimal, precision: 10, scale: 2
    add_column :mealfoods, :proteins, :decimal, precision: 10, scale: 2
    add_column :mealfoods, :carbohydrates, :decimal, precision: 10, scale: 2
    add_column :mealfoods, :fats, :decimal, precision: 10, scale: 2
    add_column :mealfoods, :fiber, :decimal, precision: 10, scale: 2

    # Aggiunge lo stato del calcolo
    add_column :mealfoods, :calculation_status, :string, default: 'pending'
    add_index :mealfoods, :calculation_status
  end
end
