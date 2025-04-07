class AddNutritionalColumnsToMeals < ActiveRecord::Migration[7.1]
  def change
    add_column :meals, :calories, :decimal, precision: 10, scale: 2, default: 0
    add_column :meals, :proteins, :decimal, precision: 10, scale: 2, default: 0
    add_column :meals, :carbohydrates, :decimal, precision: 10, scale: 2, default: 0
    add_column :meals, :fats, :decimal, precision: 10, scale: 2, default: 0
    add_column :meals, :fiber, :decimal, precision: 10, scale: 2, default: 0
  end
end
