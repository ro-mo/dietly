class MealfoodController < ApplicationController
  def show
    @mealfood = Mealfood.find(params[:id])
  end
end


