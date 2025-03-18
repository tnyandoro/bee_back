namespace :api do
  namespace :v1 do
    # Session management
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy'

    # Organizations Resource with Subdomain-Based Routing
    resources :organizations, param: :subdomain, only: [:index] do
      # ✅ Profile route inside organizations scope
      get 'profile', to: 'users#profile'

      # Nested Resources
      resources :users, only: %i[index show create update destroy] do
        collection do
          post :add_user
        end
        resources :tickets, only: [:index]
        resources :problems, only: [:index]
      end

      resources :teams, only: %i[index show create update destroy] do
        get 'users', to: 'teams#users', on: :member
      end

      resources :tickets, only: %i[index show create update destroy] do
        member do
          post :assign_to_user
          post :escalate_to_problem
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

    # Global Problems and Tickets Resources
    resources :problems, only: %i[index show create update destroy]
    resources :tickets, only: %i[index show create update destroy] do
      member do
        post :assign_to_user
        post :escalate_to_problem
      end
    end

    # Global Users Resource
    resources :users, only: %i[index show create update destroy] do
      resources :tickets, only: [:index]
    end

    # Custom route for registering an organization and its admin
    post '/register', to: 'registrations#create'
    post '/organizations/:subdomain/register_admin', to: 'registrations#register_admin', as: :register_admin
  end
end
