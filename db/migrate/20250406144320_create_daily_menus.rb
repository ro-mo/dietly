class CreateDailyMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_menus do |t|
      t.references :diet_plan, null: false, foreign_key: true
      t.integer :day_of_week
      t.text :notes

      t.timestamps
    end
  end
end
