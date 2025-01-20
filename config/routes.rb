Rails.application.routes.draw do
  # General resources
  resources :problems
  resources :tickets
  resources :users do
    resources :tickets, only: [:index] # Nested tickets under users
  end
  resources :organizations do
    resources :users, only: [:index, :create, :update, :destroy] do
      resources :tickets, only: [:index] # Nested tickets under organization and user
      resources :problems, only: [:index] # Nested problems under organization and user
    end
    resources :tickets, only: [:index] # Tickets scoped to the organization
    resources :problems, only: [:index] # Problems scoped to the organization
    resources :notifications, only: [:index] do
      member do
        patch :mark_as_read
      end
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

  # Explicit session routes
  get 'api/v1/login', to: 'api/v1/sessions#create'
  get 'api/v1/logout', to: 'api/v1/sessions#destroy'

  # API V1 Routes
  namespace :api do
    namespace :v1 do
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      resources :organizations, only: [:index, :show] do
        resources :users, only: [:index, :show] do
          resources :tickets, only: [:index] # Scoped tickets under API namespace
        end
        resources :tickets, only: [:index] # Organization-level tickets
        resources :problems, only: [:index] # Organization-level problems
      end
      resource :dashboard, only: [:show]
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route placeholder
  # root "posts#index"

  # General resources
  resources :problems, only: %i[index show create update destroy]
  resources :tickets, only: %i[index show create update destroy]
  resources :users, only: %i[index show create update destroy]
  resources :organizations, only: %i[index show create update destroy] do
    # Nested resources under organizations
    resources :users, only: %i[index show create update destroy] 
    resources :teams, only: %i[index show create update destroy] 
    resources :tickets, only: %i[index show create update destroy]  do
      member do
        post :assign_to_user 
        post :escalate_to_problem
      end
    end
    resources :teams, only: %i[index show create update destroy]
  end

  # Subdomain-specific routes
  constraints SubdomainConstraint do
    scope module: 'api/v1', path: '' do
      # Session management
      resources :sessions, only: %i[create destroy]

      # Resources under subdomain
      resources :users, only: %i[index show create update destroy]
      resources :tickets, only: %i[index show create update destroy]
      resources :problems, only: %i[index show create update destroy]
    end
  end

  # Explicit routes for login and logout
  get 'api/v1/login', to: 'api/v1/sessions#create'
  get 'api/v1/logout', to: 'api/v1/sessions#destroy'

  # API V1 Routes
  namespace :api do
    namespace :v1 do
      # Session management
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'

      # Resources
      resources :organizations, only: %i[index show]
      resource :dashboard, only: [:show] # Singular resource for dashboard
    end
  end
end
