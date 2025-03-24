Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # API V1 Routes
  namespace :api do
    namespace :v1 do
      # Session management
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      get '/profile', to: 'users#profile' # User profile endpoint

      # Organizations Resource with Subdomain-Based Routing
      resources :organizations, param: :subdomain, only: [:index] do
        # Nested Resources
        resources :users, only: %i[index show create update destroy] do
          collection do
            post :add_user # New route for adding a user to the organization
          end
          resources :tickets, only: [:index] # User-specific ticket listings
          resources :problems, only: [:index]
        end

        resources :teams, only: %i[index show create update destroy] do
          get 'users', to: 'teams#users', on: :member # New route to fetch team users
        end

        resources :tickets, only: %i[index show create update destroy] do
          member do
            post :assign_to_user
            post :escalate_to_problem
            post :resolve # Added resolve action
          end
        end
        resources :problems, only: %i[index show create update destroy]

        resources :notifications, only: [:index] do
          member do
            patch :mark_as_read
          end
        end
      end

      # Custom routes for organizations based on subdomain
      get '/organizations/:subdomain', to: 'organizations#show', as: :organization
      patch '/organizations/:subdomain', to: 'organizations#update'
      put '/organizations/:subdomain', to: 'organizations#update'
      delete '/organizations/:subdomain', to: 'organizations#destroy'

      # Global Problems and Tickets Resources (optional, consider removing if not needed)
      resources :problems, only: %i[index show create update destroy]
      resources :tickets, only: %i[index show create update destroy] do
        member do
          post :assign_to_user
          post :escalate_to_problem
          post :resolve # Added resolve action here too, if global scope is needed
        end
      end

      # Users Resource (global, consider scoping to organizations if not needed globally)
      resources :users, only: %i[index show create update destroy] do
        resources :tickets, only: [:index]
      end

      # Custom route for registering an organization and its admin
      post '/register', to: 'registrations#create'
      post '/organizations/:subdomain/register_admin', to: 'registrations#register_admin', as: :register_admin
    end
  end
end