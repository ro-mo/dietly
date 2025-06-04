Rails.application.routes.draw do
  resource :session
  resources :passwords, only: [ :new, :create, :edit, :update ] do
    get :edit, on: :collection, as: :edit
    patch :update, on: :collection
  end

  namespace :doctors do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"

    # Route per i medici
    namespace :administrations do
      get "patients_management", to: "patients#index"
      resources :patients, only: [ :edit, :update ]

      # Sostituiamo la route singola con una risorsa completa per le diete
      # get "diets_management", to: "diets#index" # Rimossa
      resources :diets, path: "diets_management", as: :diets # Usa il percorso "diets_management" ma helper standard
    end
    resources :appointments, only: [ :index, :new, :create, :edit, :update, :destroy, :show ]
  end

  namespace :patients do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"
    resource :profile, only: [ :show, :edit, :update ]
    namespace :administrations do
      get "diet_routine", to: "diet_routine"
      get "diet_history", to: "diet_history"
      get "diet_details/:id", to: "diet_details", as: :diet_details
      get "my_appointments", to: "my_appointments"
    end
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

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
