Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Global routes
      post 'validate_subdomain', to: 'organizations#validate_subdomain'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      get '/verify', to: 'sessions#verify'
      post '/register', to: 'registrations#create'
      get '/verify_admin', to: 'sessions#verify_admin'

      # Organization resources
      resources :organizations, param: :subdomain do
        member do
          get 'profile', to: 'users#profile'
          get 'tickets', to: 'organizations#tickets'
          get 'users', to: 'organizations#users'
          post 'add_user', to: 'organizations#add_user'
        end

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
  get '*path', to: 'static#index', constraints: ->(req) { !req.path.start_with?('/api') }
end