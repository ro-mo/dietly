Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]

  # Reset password con solo le azioni necessarie
  resource :password_reset, only: [:new, :create, :edit, :update], controller: "passwords"

  namespace :doctors do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"
  end

  namespace :patients do
    get "signup", to: "registrations#new"
    post "signup", to: "registrations#create"
  end

  # Controllo stato server
  get "up" => "rails/health#show", as: :rails_health_check

  # Root della pagina principale
  root "home#show"
end

