Rails.application.routes.draw do
  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # Mount ActionCable for WebSocket support
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      # Global authentication and registration routes
      post 'validate_subdomain', to: 'organizations#validate_subdomain'
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      get 'verify', to: 'sessions#verify'
      post 'refresh', to: 'sessions#refresh'
      post 'register', to: 'registrations#create'
      get 'verify_admin', to: 'sessions#verify_admin'
      post 'password/reset', to: 'passwords#reset'
      post 'password/update', to: 'passwords#update'

      # Profile route
      resource :profile, only: [:show]

      # Organization-specific routes
      resources :organizations, param: :subdomain do
        # Organization dashboard & settings
        member do
          get 'dashboard', to: 'dashboard#show'
          get 'profile', to: 'profiles#show'
          get 'tickets', to: 'organizations#tickets'
          get 'users', to: 'organizations#users'
          get 'settings', to: 'settings#index'
          put 'settings', to: 'settings#update'
          post 'upload_logo', to: 'settings#upload_logo'
          post 'add_user', to: 'organizations#add_user'
        end

        # Knowledgebase
        get 'knowledgebase', to: 'knowledgebase#index'

        # Admin registration under organization
        post 'register_admin', to: 'registrations#register_admin'

        # Nested resources for users
        resources :users, only: [:index, :show, :create, :update, :destroy] do
          resources :tickets, only: [:index]
          resources :problems, only: [:index]
        end

        # Nested teams
        resources :teams, only: [:index, :show, :create, :update] do
          member do
            get 'users'
            patch 'deactivate'
          end
        end

        # Nested tickets with custom actions
        resources :tickets, only: [:index, :show, :create, :update, :destroy] do
          collection do
            get :export
            get :debug_visibility
          end

          member do
            post :assign_to_user
            post :escalate_to_problem
            post :resolve
            get 'attachments/:attachment_id', to: 'tickets#download_attachment', as: :download_attachment
          end

          # Nested comments
          resources :comments, only: [:index, :create]
        end

        # Nested problems
        resources :problems, only: [:index, :show, :create, :update, :destroy]

        # Nested notifications
        resources :notifications, only: [:index, :show, :create, :update, :destroy] do
          member { patch :mark_as_read }
        end
      end
    end
  end

  # Root route
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ message: 'API is live' }.to_json]] }

  # Catch-all for frontend or unknown routes
  get '*path', to: proc { [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not found' }.to_json]] },
               constraints: ->(req) { !req.path.start_with?('/api', '/cable', '/rails') }
end
