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
    Rails.logger.debug "=== CREATE DIET PLAN START ==="
    Rails.logger.debug "Received Params for Create: #{params.inspect}"
    
    # Usa diet_plan_params per includere tutti gli attributi nidificati
    @diet_plan = DietPlan.new(diet_plan_params)
    @diet_plan.doctor = Current.user

    # Assicurati che tutti i giorni e i pasti esistano
    (1..7).each do |day|
      daily_menu = @diet_plan.daily_menus.find_or_initialize_by(day_of_week: day)
      daily_menu.diet_plan = @diet_plan # Imposta l'associazione
      
      meal_types = %w[colazione snack_mattina pranzo snack_pomeriggio cena]
      meal_times = {
        'colazione' => '08:00',
        'snack_mattina' => '11:00',
        'pranzo' => '13:00',
        'snack_pomeriggio' => '16:00',
        'cena' => '20:00'
      }
      
      meal_types.each do |type|
        meal = daily_menu.meals.find_or_initialize_by(meal_type: type)
        meal.daily_menu = daily_menu # Imposta l'associazione
        meal.description = "#{type.titleize} del giorno"
        meal.time_suggestion = meal_times[type]
      end
    end

    if @diet_plan.save
      Rails.logger.debug "=== DIET PLAN CREATED SUCCESSFULLY ==="
      Rails.logger.debug "Created Diet Plan:"
      Rails.logger.debug "Daily Menus: #{@diet_plan.daily_menus.count}"
      
      @diet_plan.daily_menus.each do |menu|
        Rails.logger.debug "Menu #{menu.day_of_week}:"
        menu.meals.each do |meal|
          Rails.logger.debug "  Meal #{meal.meal_type}:"
          Rails.logger.debug "    Mealfoods: #{meal.mealfoods.count}"
          meal.mealfoods.each do |mealfood|
            Rails.logger.debug "      - #{mealfood.ingredient_name} (#{mealfood.quantity} #{mealfood.unit})"
          end
        end
      end
      
      after_save_actions
      redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico creato con successo.'
    else
      Rails.logger.debug "=== DIET PLAN CREATION FAILED ==="
      Rails.logger.debug "Errors: #{@diet_plan.errors.full_messages}"
      @patient = User.find_by(id: params[:diet_plan][:patient_id], type: 'Patient') if params[:diet_plan]
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    Rails.logger.debug "=== EDIT DIET PLAN START (Ensuring all Menus and Meals) ==="
    @diet_plan = DietPlan.find(params[:id])
    Rails.logger.debug "Diet Plan ID: #{@diet_plan.id}"

    meal_types = %w[colazione snack_mattina pranzo snack_pomeriggio cena]
    meal_times = {
      'colazione' => '08:00',
      'snack_mattina' => '11:00',
      'pranzo' => '13:00',
      'snack_pomeriggio' => '16:00',
      'cena' => '20:00'
    }

    # Ensure all 7 daily menus exist and all 5 meal types exist within each
    (1..7).each do |day_of_week_num|
      daily_menu = @diet_plan.daily_menus.find_or_initialize_by(day_of_week: day_of_week_num)
      daily_menu.diet_plan = @diet_plan # Ensure association if new

      Rails.logger.debug "  Daily Menu for Day #{day_of_week_num} (ID: #{daily_menu.id || 'new'}), Meals count: #{daily_menu.meals.count}"

      # Ensure all meal types exist within this daily menu
      existing_meal_types = daily_menu.meals.map(&:meal_type).compact

      meal_types.each do |meal_type_name|
        unless existing_meal_types.include?(meal_type_name)
          Rails.logger.debug "    Building missing meal type: #{meal_type_name}"
          daily_menu.meals.build(
            meal_type: meal_type_name,
            description: "#{meal_type_name.titleize} del giorno",
            time_suggestion: meal_times[meal_type_name]
          )
        else
           Rails.logger.debug "    Meal type already exists: #{meal_type_name}"
        end
      end

      # Sort meals by time suggestion for consistent display in the form (in memory)
      daily_menu.meals.target.sort_by! { |meal| meal_times[meal.meal_type] || '23:59' } # Sort meals in memory by modifying the target array

      Rails.logger.debug "    Meals count (after build and sort): #{daily_menu.meals.count}"
      daily_menu.meals.each do |meal|
          Rails.logger.debug "      Meal ID: #{meal.id || 'new'}, Type: #{meal.meal_type}, Mealfoods count: #{meal.mealfoods.count}"
      end

    end

    # Ensure all daily menus are in the collection, even if not yet saved and sort them
    # Convert to array before sorting to avoid issues with CollectionProxy and bang methods
    @diet_plan.daily_menus = @diet_plan.daily_menus.to_a.uniq(&:day_of_week).sort_by(&:day_of_week)

    Rails.logger.debug "Total Daily Menus in collection (after all builds and sort): #{@diet_plan.daily_menus.count}"
    Rails.logger.debug "=== EDIT DIET PLAN END ==="
  end

  def update
    Rails.logger.debug "=== UPDATE DIET PLAN ==="
    Rails.logger.debug "Params: #{params.inspect}"
    
    # Imposta manualmente i campi daily_menu_id e diet_plan_id
    params[:diet_plan][:daily_menus_attributes]&.each do |_, daily_attrs|
      daily_attrs[:diet_plan_id] = @diet_plan.id
      
      daily_attrs[:meals_attributes]&.each do |_, meal_attrs|
        meal_attrs[:daily_menu_id] = daily_attrs[:id] if daily_attrs[:id].present?
        
        # Log per i mealfoods
        if meal_attrs[:mealfoods_attributes].present?
          Rails.logger.debug "Mealfoods per meal #{meal_attrs[:id]}:"
          meal_attrs[:mealfoods_attributes].each do |_, mealfood_attrs|
            Rails.logger.debug "  - #{mealfood_attrs[:ingredient_name]} (#{mealfood_attrs[:quantity]} #{mealfood_attrs[:unit]})"
          end
        end
      end
    end
    
    if @diet_plan.update(diet_plan_params)
      Rails.logger.debug "=== DIET PLAN UPDATED SUCCESSFULLY ==="
      Rails.logger.debug "Updated Diet Plan:"
      Rails.logger.debug "Daily Menus: #{@diet_plan.daily_menus.count}"
      
      @diet_plan.daily_menus.each do |menu|
        Rails.logger.debug "Menu #{menu.day_of_week}:"
        menu.meals.each do |meal|
          Rails.logger.debug "  Meal #{meal.meal_type}:"
          Rails.logger.debug "    Mealfoods: #{meal.mealfoods.count}"
          meal.mealfoods.each do |mealfood|
            Rails.logger.debug "      - #{mealfood.ingredient_name} (#{mealfood.quantity} #{mealfood.unit})"
          end
        end
      end
      
      after_save_actions
      redirect_to doctors_administrations_diets_path, notice: 'Piano dietetico aggiornato con successo.'
    else
      Rails.logger.debug "=== DIET PLAN UPDATE FAILED ==="
      Rails.logger.debug "Errors: #{@diet_plan.errors.full_messages}"
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
    Rails.logger.debug "=== DIET PLAN PARAMS ==="
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
      Rails.logger.debug "Whitelisted params: #{whitelisted.inspect}"
      
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