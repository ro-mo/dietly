Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :doctors do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"

    # Route per i medici
    namespace :administrations do
      get "patients_management", to: "patients#index"
      get "diets_management", to: "diets#index"
      get "appointment_management" , to: "appointment#index"
      resources :patients, only: [:edit, :update]

      namespace :diets do
        get "diet_creation", to: "diet_creation"
      end
    end
  end

  namespace :patients do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"
    get "diet_routine", to: "administrations#diet_routine"
    get "doctor_appointments", to: "administrations#doctor_appointments"
  end

  resources :appointments

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#show"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
