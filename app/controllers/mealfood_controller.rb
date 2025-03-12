class MealfoodController < ApplicationController
  def show
    @mealfood = Mealfood.find(params[:id])
  end

  def create
    @mealfood = Mealfood.new(mealfood_params)
    if @mealfood.save
      redirect_to @mealfood, notice: "Mealfood created successfully"
  end
end


