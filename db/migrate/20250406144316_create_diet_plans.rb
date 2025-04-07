class CreateDietPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :diet_plans do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users } # Assumendo che Patient erediti da User
      t.references :doctor, null: false, foreign_key: { to_table: :users } # Assumendo che Doctor erediti da User
      t.string :title
      t.date :start_date
      t.date :end_date
      t.boolean :active, default: true
      t.text :notes

      t.timestamps
    end
  end
end
