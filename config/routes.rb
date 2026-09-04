# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 routes
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      # Authentication & Identity
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/logout", to: "auth#logout"
      get "me", to: "me#show"
    end
  end
end
