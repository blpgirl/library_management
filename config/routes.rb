Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes with Devise-JWT
  # Using the custom controllers for sessions and registrations
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # API routes
  namespace :api do
    namespace :v1 do
      resources :books
      resources :authors, only: [:index, :create, :update, :destroy]
      resources :genres, only: [:index, :create, :update, :destroy]
      resources :borrowings, only: [:index, :create, :update] do
        put :cancel, on: :member
      end
      get "/dashboards/librarian", to: "dashboards#librarian"
      get "/dashboards/member", to: "dashboards#member"
    end
  end
end
