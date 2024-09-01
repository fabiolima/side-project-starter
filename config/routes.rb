Rails.application.routes.draw do
  # Skip registration because admins should be manually created.
  devise_for :admins, controllers: {
    sessions: "admins/sessions",
    registrations: "admins/registrations",
    passwords: "admins/passwords"
  }

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  # Administration routes for user management and whatever you want to be admin only.
  namespace :admin do
    namespace :dashboard do
      get "/" => "home#index" # Admin::Dashboard::HomeController
      resources :users, except: [ :create, :edit, :new ] do
        post :ban, on: :member
        post :unban, on: :member
      end
    end
  end

  # User private area
  namespace :app do
    namespace :dashboard do
      get "/" => "home#index" # Admin::Dashboard::HomeController

      resources :profiles, except: [ :index, :destroy, :create ]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  #
  root to: "home#index"
  get "about", to: "home#about"
end
