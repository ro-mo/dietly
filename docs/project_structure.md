# Dietly Project Structure

## Overview
Dietly is a Ruby on Rails application for managing diet plans and patient-doctor relationships. The application allows dietitians to create and manage customized diet plans for their patients, track progress, and generate shopping lists.

## System Requirements
- Ruby 3.3.5
- Rails 8.0.1

## Core Entities and Relationships

### User Management
- **User** (Base class)
  - Attributes:
    - email_address (string)
    - password_digest (string)
    - type (string) - STI for Doctor/Patient
    - first_name (string)
    - last_name (string)
    - phone (string)
    - fiscal_code (string)
    - doctor_id (integer) - For patients
    - albo_id (string) - For doctors
    - verification_status (string)

- **Doctor** (inherits from User)
  - Attributes:
    - unique_code (string)
  - Relationships:
    - has_many :patients
    - has_many :diet_plans, through: :patients
  - Methods:
    - all_active_diet_plans
    - patients_with_expiring_diets
    - create_patient
    - notify_expiring_diets

- **Patient** (inherits from User)
  - Relationships:
    - belongs_to :doctor
    - has_many :diet_plans
  - Methods:
    - current_diet_plan
    - calculate_shopping_list
    - diet_history
    - notify_doctor_diet_expiring

### Diet Management
- **DietPlan**
  - Attributes:
    - patient_id (integer)
    - start_date (date)
    - end_date (date)
    - active (boolean)
  - Relationships:
    - belongs_to :patient
    - has_many :daily_menus
  - Methods:
    - calculate_shopping_list
    - duplicate
    - days_until_expiration
    - notify_expiration

- **DailyMenu**
  - Attributes:
    - diet_plan_id (integer)
    - day_of_week (integer)
  - Relationships:
    - belongs_to :diet_plan
    - has_many :meals
  - Methods:
    - total_calories
    - meals_by_type
    - duplicate

- **Meal**
  - Attributes:
    - daily_menu_id (integer)
    - meal_type (string)
    - calories (float)
    - proteins (float)
    - carbohydrates (float)
    - fats (float)
    - fiber (float)
  - Relationships:
    - belongs_to :daily_menu
    - has_many :mealfood
  - Methods:
    - add_food
    - remove_food
    - update_quantity
    - nutritional_values

### Authentication
- **Session**
  - Attributes:
    - user_id (integer)
    - ip_address (string)
    - user_agent (string)
  - Relationships:
    - belongs_to :user

## Database Schema
The application uses several database schemas:

1. **Main Schema** (schema.rb)
   - Contains core application tables
   - Manages users, sessions, and relationships

2. **Queue Schema** (queue_schema.rb)
   - Manages background job processing
   - Handles job execution states and scheduling

3. **Cache Schema** (cache_schema.rb)
   - Manages application caching
   - Stores cached entries with size limits

4. **Cable Schema** (cable_schema.rb)
   - Handles real-time communication
   - Manages WebSocket messages and channels

## Frontend Structure
- Uses Tailwind CSS for styling
- Stimulus.js for JavaScript interactions
- Turbo for enhanced navigation
- Custom color scheme with marmorean palette

## Security Features
- Session-based authentication
- Secure password handling
- HTTP-only cookies
- Same-site cookie policy
- Modern browser requirements

## Background Processing
- Solid Queue for job processing
- Recurring task support
- Job prioritization
- Concurrency management

## Deployment Configuration
- Kamal for deployment management
- Docker support
- Asset pipeline configuration
- Database backup recommendations 