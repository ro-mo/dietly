class CreateFoods < ActiveRecord::Migration[7.1]
  def change
    create_table :foods do |t|
      t.string :name
      t.string :category
      t.text :description
      t.decimal :calories_per_100g, precision: 8, scale: 2
      t.decimal :proteins_per_100g, precision: 8, scale: 2
      t.decimal :carbohydrates_per_100g, precision: 8, scale: 2
      t.decimal :fats_per_100g, precision: 8, scale: 2
      t.decimal :fiber_per_100g, precision: 8, scale: 2
      t.string :serving_size

      t.timestamps
    end
    add_index :foods, :name
    add_index :foods, :category
  end
end
