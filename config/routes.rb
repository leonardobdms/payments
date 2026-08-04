Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :users, path: "/" do
        post "register", to: "registrations#create"
        post "login", to: "sessions#create"
        post "refresh", to: "sessions#refresh"
        delete "logout", to: "sessions#destroy"

        resource :me, only: %i[show update destroy], controller: "me"
      end

      resource :merchant, only: %i[show create update], controller: "merchants/merchant"
    end
  end
end
