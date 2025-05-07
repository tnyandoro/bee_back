Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount ActionCable for WebSocket support
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      # Global routes (no organization needed)
      post 'validate_subdomain', to: 'organizations#validate_subdomain'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      get '/verify', to: 'sessions#verify'
      post '/register', to: 'registrations#create' # Moved outside organization scope
      get '/verify_admin', to: 'sessions#verify_admin'

      # Profile route (should be scoped under organization or user)
      resource :profile, only: [:show]

      # Organization resources
      resources :organizations, param: :subdomain do
        # Organization-level routes
        member do
          get 'profile', to: 'profiles#show'
          get 'tickets', to: 'organizations#tickets'
          get 'users', to: 'organizations#users'
          post 'add_user', to: 'organizations#add_user'
        end

        # Registration route for admin (organization-specific)
        post 'register_admin', to: 'registrations#register_admin'

        # Nested resources
        resources :users, only: [:index, :show, :create, :update, :destroy] do
          resources :tickets, only: [:index]
          resources :problems, only: [:index]
        end

        resources :teams, only: [:index, :show, :create, :update, :destroy] do
          get 'users', on: :member
        end

        resources :tickets, only: [:index, :show, :create, :update, :destroy] do
          post :assign_to_user, on: :member
          post :escalate_to_problem, on: :member
          post :resolve, on: :member
        end

        resources :problems, only: [:index, :show, :create, :update, :destroy]

        resources :notifications, only: [:index, :show, :create, :update, :destroy] do
          patch :mark_as_read, on: :member
        end
      end
    end
  end

  # Catch-all route for React SPA (excluding ActionCable and API routes)
  get '*path', to: 'static#index', constraints: ->(req) { !req.path.start_with?('/api', '/cable') }
end