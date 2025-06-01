class AddCalculationStatusToMealfoods < ActiveRecord::Migration[7.1]
  def change
    add_column :mealfoods, :calculation_status, :string, default: 'pending'
    add_index :mealfoods, :calculation_status
  end
end
