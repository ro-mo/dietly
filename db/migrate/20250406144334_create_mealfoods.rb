class CreateMealfoods < ActiveRecord::Migration[7.1]
  def change
    create_table :mealfoods do |t|
      t.references :meal, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.decimal :quantity, precision: 8, scale: 2
      t.string :unit
      t.text :notes

      t.timestamps
    end
  end
end
