# Dietly

A Ruby on Rails application for managing diet plans and patient-doctor relationships. This application allows dietitians to create and manage customized diet plans for their patients, track progress, and generate shopping lists.

## System Requirements

- Ruby 3.3.5
- Rails 8.0.1

## Features

- Doctor and Patient authentication
- Diet plan management with weekly schedules
- Automated shopping list generation
- Diet expiration notifications
- Patient progress tracking
- Meal and food database management

## Class Diagram

```mermaid
classDiagram
    class User {
        +string email
        +string encrypted_password
        +string type
        +string first_name
        +string last_name
        +string phone
        +datetime created_at
        +datetime updated_at
        +authenticate()
        +reset_password()
        +send_reset_password_instructions()
    }

    class Doctor {
        +string unique_code
        +all_active_diet_plans()
        +patients_with_expiring_diets()
        +create_patient(attributes)
        +notify_expiring_diets()
    }

    class Patient {
        +integer doctor_id
        +current_diet_plan()
        +calculate_shopping_list(days)
        +diet_history()
        +notify_doctor_diet_expiring()
    }

    class DietPlan {
        +integer patient_id
        +date start_date
        +date end_date
        +boolean active
        +calculate_shopping_list(days)
        +duplicate()
        +days_until_expiration()
        +notify_expiration()
    }

    class DailyMenu {
        +integer diet_plan_id
        +integer day_of_week
        +total_calories()
        +meals_by_type()
        +duplicate()
    }

    class Meal {
        +integer daily_menu_id
        +string meal_type
        +float total_calories
        +add_food(food, quantity)
        +remove_food(food)
        +update_quantity(food, quantity)
    }

    class MealFood {
        +integer meal_id
        +integer food_id
        +float quantity
        +string unit
        +calories()
        +convert_unit(new_unit)
    }

    class Food {
        +string name
        +string category
        +float calories_per_100g
        +calculate_calories(quantity)
        +similar_foods()
    }

    class Notification {
        +integer user_id
        +integer diet_plan_id
        +string message
        +boolean read
        +datetime sent_at
        +mark_as_read()
        +deliver()
    }

    User <|-- Doctor
    User <|-- Patient
    Doctor "1" --o "many" Patient
    Patient "1" --o "many" DietPlan
    DietPlan "1" --* "7" DailyMenu
    DailyMenu "1" --* "many" Meal
    Meal "1" --* "many" MealFood
    MealFood "many" --o "1" Food
    User "1" --o "many" Notification
    DietPlan "1" --o "many" Notification
```

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
bin/setup
```

3. Start the server:
```bash
bin/dev
```

The application will be available at `http://localhost:3000`

## Testing

To run the test suite:

```bash
bin/rails test
```

## Key Components

### Authentication
- Scaffolded with Rails Authentication Generator
- Single Table Inheritance (STI) for User model
- Separate Doctor and Patient models inheriting from User

### Models
- `User`: Base class for authentication and common user attributes
- `Doctor`: Manages patients and their diet plans
- `Patient`: Has diet plans and shopping lists
- `DietPlan`: Contains weekly meal schedules
- `DailyMenu`: Represents a day's worth of meals
- `Meal`: Individual meals (breakfast, lunch, etc.)
- `Food`: Food items database
- `MealFood`: Join table with quantities
- `Notification`: System notifications (To Be Defined)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- Thanks to all contributors who have helped shape this project
- Built with Ruby on Rails
- Styled with Tailwind CSS