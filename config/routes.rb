Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # API V1 Routes
  namespace :api do
    namespace :v1 do
      # Session management
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'

      # Resources
      resources :organizations, only: %i[index show create update destroy] do
        resources :users, only: %i[index show create update destroy] do
          resources :tickets, only: [:index]
          resources :problems, only: [:index]
        end
        resources :teams, only: %i[index show create update destroy]
        resources :tickets, only: %i[index show create update destroy]
        resources :problems, only: %i[index show create update destroy]
        resources :notifications, only: [:index] do
          member do
            patch :mark_as_read
          end
        end
      end

      resources :problems, only: %i[index show create update destroy]
      resources :tickets, only: %i[index show create update destroy] do
        member do
          post :assign_to_user
          post :escalate_to_problem
        end
      end
      resources :users, only: %i[index show create update destroy] do
        resources :tickets, only: [:index]
      end

      # Custom route for registering an organization and its admin
      post '/register', to: 'registrations#create'
    end
  end

  # Root route placeholder
  # root "posts#index"
end