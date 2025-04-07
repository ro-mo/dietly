class Doctors::Administrations::DietsController < ApplicationController
  before_action :ensure_doctor
  before_action :set_diet_plan, only: [:edit, :update, :destroy]
  before_action :set_patients, only: [:new, :create, :edit, :update]

  def index
    @diet_plans = DietPlan.where(doctor: Current.user)
                          .includes(:patient)
                          .order(start_date: :desc)
  end

  def new
    @patient = User.find_by(id: params[:patient_id], type: 'Patient')
    if @patient.nil? && params[:patient_id].present?
      redirect_to doctors_administrations_patients_management_path, alert: "Paziente non trovato."
      return
    end

    @diet_plan = DietPlan.new
    @diet_plan.patient = @patient if @patient

    build_nested_resources
  end

  def create
    @diet_plan = DietPlan.new(diet_plan_params)
    @diet_plan.doctor = Current.user

    if @diet_plan.save
      after_save_actions
      redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico creato con successo.'
    else
      @patient = User.find_by(id: params[:diet_plan][:patient_id], type: 'Patient') if params[:diet_plan]
      build_nested_resources if @diet_plan.daily_menus.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    build_nested_resources
  end

  def update
    if @diet_plan.update(diet_plan_params)
      after_save_actions
      redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico aggiornato con successo.'
    else
      build_nested_resources if @diet_plan.daily_menus.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diet_plan.destroy
    redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico eliminato con successo.', status: :see_other
  end

  private

  def ensure_doctor
    unless Current.user.is_a?(Doctor)
      redirect_to root_path, alert: "Non hai i permessi necessari per accedere a questa pagina."
    end
  end

  def set_diet_plan
    @diet_plan = DietPlan.find_by!(id: params[:id], doctor_id: Current.user.id)
  rescue ActiveRecord::RecordNotFound
    redirect_to doctors_administrations_diets_path, alert: 'Piano dietetico non trovato o non autorizzato.'
  end

  def set_patients
    @patients = Current.user.patients.order(:last_name, :first_name)
    @patient = @diet_plan.patient if @diet_plan&.persisted?
  end

  def diet_plan_params
    params.require(:diet_plan).permit(
      :patient_id, :title, :start_date, :end_date, :active, :notes,
      daily_menus_attributes: [
        :id, :day_of_week, :notes, :_destroy,
        meals_attributes: [
          :id, :meal_type, :time_suggestion, :description, :_destroy,
          mealfoods_attributes: [
            :id, :ingredient_name, :quantity, :unit, :notes, :_destroy
          ]
        ]
      ]
    ).tap do |whitelisted|
      whitelisted[:daily_menus_attributes]&.each do |_, daily_attrs|
        daily_attrs[:meals_attributes]&.each do |_, meal_attrs|
          meal_attrs[:mealfoods_attributes]&.reject! { |_, food_attrs| food_attrs[:ingredient_name].blank? && food_attrs[:quantity].blank? }
        end
      end
    end
  end

  def build_nested_resources
    needed_days = (1..7).to_a - @diet_plan.daily_menus.map(&:day_of_week)
    needed_days.each { |day| @diet_plan.daily_menus.build(day_of_week: day) }

    meal_types = %w[colazione snack_mattina pranzo snack_pomeriggio cena]
    @diet_plan.daily_menus.each do |daily_menu|
      needed_meal_types = meal_types - daily_menu.meals.map(&:meal_type)
      needed_meal_types.each { |type| daily_menu.meals.build(meal_type: type) }
    end
  end

  def after_save_actions
    @diet_plan.meals.each do |meal|
      meal.mealfoods.each do |mealfood|
        CalculateNutritionalValuesJob.perform_later(mealfood.id)
      end
    end
  end
end
