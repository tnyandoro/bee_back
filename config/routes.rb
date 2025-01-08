require_relative '../app/constraints/subdomain_constraint'

Rails.application.routes.draw do
  # General resources
  resources :problems
  resources :tickets
  resources :users
  resources :organizations do
    resources :users, only: [:index, :create, :update, :destroy]
    resources :tickets, only: %i[index show create update destroy]
    resources :teams, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  end
  

  # Subdomain-specific routes
  constraints SubdomainConstraint do
    scope module: 'api/v1', path: '' do
      resources :sessions, only: [:create, :destroy]
      resources :users
      resources :tickets
      resources :problems
    end
  end

  get 'api/v1/login', to: 'api/v1/sessions#create' # Explicit route for login
  get 'api/v1/logout', to: 'api/v1/sessions#destroy' # Explicit route for logout

  # API V1 Routes
  namespace :api do
    namespace :v1 do
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      resources :organizations, only: [:index, :show]
      resource :dashboard, only: [:show]
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route placeholder
  # root "posts#index"
end
