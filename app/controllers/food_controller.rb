class FoodController < ApplicationController
  def show
    @food = Food.find(params[:id])
  end

  def create
    @food = Food.new(food_params)
    if @food.save
      redirect_to @food, notice: "Food created successfully"
  end

  
end


