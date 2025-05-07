class Doctors::Administrations::DietsController < ApplicationController
  before_action :ensure_doctor
  before_action :set_diet_plan, only: [:edit, :update, :destroy]
  before_action :set_patients, only: [:new, :create, :edit, :update]

  def index
    # Base query: tutte le diete del medico corrente
    diet_plans_query = DietPlan.where(doctor: Current.user).includes(:patient)
    
    # Applicazione del filtro per paziente se presente
    if params[:patient_id].present?
      diet_plans_query = diet_plans_query.where(patient_id: params[:patient_id])
      @patient = Patient.find_by(id: params[:patient_id])
    end
    
    # Ordinamento finale
    @diet_plans = diet_plans_query.order(start_date: :desc)
  end

  def new
    @patient = User.find_by(id: params[:patient_id], type: 'Patient')
    if @patient.nil? && params[:patient_id].present?
      redirect_to doctors_administrations_patients_management_path, alert: "Paziente non trovato."
      return
    end

    @diet_plan = DietPlan.new
    @diet_plan.patient = @patient if @patient
    
    # Crea manualmente i giorni della settimana e i pasti
    (1..7).each do |day|
      daily_menu = @diet_plan.daily_menus.build(day_of_week: day)
      
      # Crea tutti i tipi di pasti per ogni giorno
      meal_types = %w[colazione snack_mattina pranzo snack_pomeriggio cena]
      meal_times = {
        'colazione' => '08:00',
        'snack_mattina' => '11:00',
        'pranzo' => '13:00',
        'snack_pomeriggio' => '16:00',
        'cena' => '20:00'
      }
      
      meal_types.each do |type|
        daily_menu.meals.build(
          meal_type: type,
          description: "#{type.titleize} del giorno",
          time_suggestion: meal_times[type]
        )
      end
    end
  end

  def create
    # Crea prima il piano dietetico senza le associazioni nidificate
    @diet_plan = DietPlan.new(
      patient_id: params[:diet_plan][:patient_id],
      title: params[:diet_plan][:title],
      start_date: params[:diet_plan][:start_date],
      end_date: params[:diet_plan][:end_date],
      active: params[:diet_plan][:active],
      notes: params[:diet_plan][:notes]
    )
    @diet_plan.doctor = Current.user

    # Salva il piano dietetico
    if @diet_plan.save
      # Crea i giorni della settimana e i pasti
      (1..7).each do |day|
        daily_menu = @diet_plan.daily_menus.create!(day_of_week: day)
        
        # Crea tutti i tipi di pasti per ogni giorno
        meal_types = %w[colazione snack_mattina pranzo snack_pomeriggio cena]
        meal_times = {
          'colazione' => '08:00',
          'snack_mattina' => '11:00',
          'pranzo' => '13:00',
          'snack_pomeriggio' => '16:00',
          'cena' => '20:00'
        }
        
        meal_types.each do |type|
          daily_menu.meals.create!(
            meal_type: type,
            description: "#{type.titleize} del giorno",
            time_suggestion: meal_times[type]
          )
        end
      end
      
      after_save_actions
      redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico creato con successo.'
    else
      @patient = User.find_by(id: params[:diet_plan][:patient_id], type: 'Patient') if params[:diet_plan]
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Imposta manualmente i campi daily_menu_id e diet_plan_id
    params[:diet_plan][:daily_menus_attributes]&.each do |_, daily_attrs|
      daily_attrs[:diet_plan_id] = @diet_plan.id
      
      daily_attrs[:meals_attributes]&.each do |_, meal_attrs|
        meal_attrs[:daily_menu_id] = daily_attrs[:id] if daily_attrs[:id].present?
      end
    end
    
    if @diet_plan.update(diet_plan_params)
      after_save_actions
      redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico aggiornato con successo.'
    else
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
      # Assicurati che i daily_menus abbiano un day_of_week
      whitelisted[:daily_menus_attributes]&.each do |_, daily_attrs|
        daily_attrs[:day_of_week] ||= 1 if daily_attrs[:day_of_week].blank?
        
        # Assicurati che i meals abbiano un meal_type e time_suggestion
        daily_attrs[:meals_attributes]&.each do |_, meal_attrs|
          meal_attrs[:meal_type] ||= 'colazione' if meal_attrs[:meal_type].blank?
          meal_attrs[:time_suggestion] ||= '08:00' if meal_attrs[:time_suggestion].blank?
          meal_attrs[:description] ||= "#{meal_attrs[:meal_type].titleize} del giorno" if meal_attrs[:description].blank?
          
          # Rimuovi i mealfoods vuoti
          meal_attrs[:mealfoods_attributes]&.reject! { |_, food_attrs| food_attrs[:ingredient_name].blank? && food_attrs[:quantity].blank? }
        end
      end
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