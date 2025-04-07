class CreateMeals < ActiveRecord::Migration[7.1]
  def change
    create_table :meals do |t|
      t.references :daily_menu, null: false, foreign_key: true
      t.string :meal_type
      t.string :time_suggestion
      t.text :description

      t.timestamps
    end
  end
end
