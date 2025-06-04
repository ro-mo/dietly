class AddPreparationInstructionsToMeals < ActiveRecord::Migration[8.0]
  def change
    add_column :meals, :preparation_instructions, :text
  end
end
