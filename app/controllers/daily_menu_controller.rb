class DailyMenuController < ApplicationController
  
  def show
    @daily_menu = DailyMenu.find(params[:id])
  end
end
