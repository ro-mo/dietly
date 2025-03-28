Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :doctors do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"

    # Route per i medici
    get "patients_management", to: "administrations#patients_management"
    get "diets_management", to: "administrations#diets_management"
  end

  namespace :patients do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"

    # Route per i pazienti
    get "diet_routine", to: "administrations#diet_routine"
    get "doctor_appointments", to: "administrations#doctor_appointments"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#show"
end
