class DailyMenuController < ApplicationController
  
  def show
    @daily_menu = DailyMenu.find(params[:id])
  end

  def create
    @daily_menu = DailyMenu.new(daily_menu_params)
    if @daily_menu.save
      redirect_to @daily_menu, notice: "Daily menu created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def daily_menu_params
    params.require(:daily_menu).permit(:name, :description)
  end

end
