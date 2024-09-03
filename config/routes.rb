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

  namespace :purchase do
    resources :checkouts
  end

  resources :subscriptions

  scope controller: :static do
    get :pricing
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # On development enviroment run: stripe listen --forward-to localhost:3000/stripe/webhooks
  post "stripe/webhooks", to: "stripe/webhooks#create"

  root to: "home#index"
end
