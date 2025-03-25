Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Session management (global, as it’s needed for login before organization scoping)
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'

      # Registration routes (global, as they’re needed for initial setup)
      post '/register', to: 'registrations#create'

      # Organization management routes with proper scoping
      resources :organizations, param: :subdomain, only: %i[index show update destroy] do
        # Profile route
        get 'profile', to: 'users#profile'

        # Register admin for an organization
        post 'register_admin', to: 'registrations#register_admin', as: :register_admin

        # Users scoped to organization
        resources :users, only: %i[index show create update destroy] do
          # Removed the add_user route since the method doesn't exist in UsersController
          # If needed, you can implement the add_user method and uncomment this
          # collection do
          #   post :add_user
          # end
          resources :tickets, only: [:index]
          resources :problems, only: [:index]
        end

        # Teams scoped to organization
        resources :teams, only: %i[index show create update destroy] do
          get 'users', to: 'teams#users', on: :member
        end

        # Tickets scoped to organization
        resources :tickets, only: %i[index show create update destroy] do
          member do
            post :assign_to_user
            post :escalate_to_problem
            post :resolve
          end
        end

        # Problems scoped to organization
        resources :problems, only: %i[index show create update destroy]

        # Notifications scoped to organization
        resources :notifications, only: [:index] do
          member do
            patch :mark_as_read
          end
        end
      end
    end
  end
end