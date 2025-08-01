# config/routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount ActionCable for WebSocket support
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      # 🔓 Global routes (no organization needed)
      post 'validate_subdomain', to: 'organizations#validate_subdomain'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      get '/verify', to: 'sessions#verify'
      get '/verify_admin', to: 'sessions#verify_admin'
      post '/register', to: 'registrations#create'
      post '/password/reset', to: 'passwords#reset'
      post '/password/update', to: 'passwords#update'

      # 🧑 Profile & Permissions (global, scoped by auth token)
      resource :profile, only: [:show]
      get '/permissions', to: 'permissions#show'  # ← Newly added

      # 🏢 Organization resources (scoped by :subdomain)
      resources :organizations, param: :subdomain do
        # Organization-level routes
        member do
          post '/upload_logo', to: 'settings#upload_logo'
          get 'dashboard', to: 'dashboard#show'
          get 'profile', to: 'profiles#show'  # Org-specific profile (if needed)
          get 'tickets', to: 'organizations#tickets'
          get 'users', to: 'organizations#users'
          post 'add_user', to: 'organizations#add_user'
          get 'settings', to: 'settings#index'
          put 'settings', to: 'settings#update'
        end

        # Admin registration
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
          collection do
            get :export
          end
          member do
            post :assign_to_user
            post :escalate_to_problem
            post :resolve
          end
        end

        resources :problems, only: [:index, :show, :create, :update, :destroy]

        resources :notifications, only: [:index, :show, :create, :update, :destroy] do
          patch :mark_as_read, on: :member
        end
      end
    end
  end

  # ✅ Root route
  root to: proc {
    [200, { 'Content-Type' => 'application/json' }, [{ message: 'API is live' }.to_json]]
  }

  # ✅ Fallback for frontend
  get '*path', to: proc {
    [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
  }, constraints: ->(req) { !req.path.start_with?('/api', '/cable', '/rails') }
end