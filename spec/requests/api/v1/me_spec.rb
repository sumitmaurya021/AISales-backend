# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Me", type: :request do
  let!(:user) { create(:user, name: "Anita Roy", email: "anita@leadflow.ai") }
  let!(:org) { create(:organization, name: "Roy Realty") }
  let!(:membership) { create(:membership, user: user, organization: org, role: "admin") }
  let(:valid_token) { JsonWebToken.encode(user_id: user.id, organization_id: org.id) }

  describe "GET /api/v1/me" do
    context "with valid JWT token in Authorization header" do
      it "returns 200 OK with authenticated user, active organization, and role" do
        get "/api/v1/me", headers: { "Authorization" => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json["user"]["id"]).to eq(user.id)
        expect(json["user"]["name"]).to eq("Anita Roy")
        expect(json["user"]["email"]).to eq("anita@leadflow.ai")
        expect(json["organization"]["id"]).to eq(org.id)
        expect(json["organization"]["name"]).to eq("Roy Realty")
        expect(json["role"]).to eq("admin")
        expect(json["memberships"].length).to eq(1)
      end
    end

    context "without Authorization header" do
      it "returns 401 Unauthorized" do
        get "/api/v1/me"

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json["error"]).to eq("Authentication token required")
      end
    end

    context "with an invalid or expired token" do
      it "returns 401 Unauthorized" do
        get "/api/v1/me", headers: { "Authorization" => "Bearer malformed.invalid.token" }

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json["error"]).to eq("Invalid or expired authentication token")
      end
    end
  end
end
