# frozen_string_literal: true

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins = ENV.fetch("CORS_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173")
                         .split(",")
                         .map(&:strip)

    origins allowed_origins

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
