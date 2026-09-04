# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/signup" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            name: "Rahul Sharma",
            email: "rahul@leadflow.ai",
            password: "password123"
          },
          organization: {
            name: "Acme Estates",
            timezone: "Asia/Kolkata"
          }
        }
      end

      it "creates user, organization, owner membership and returns 201 Created with JWT token" do
        expect do
          post "/api/v1/auth/signup", params: valid_params, as: :json
        end.to change(User, :count).by(1)
          .and change(Organization, :count).by(1)
          .and change(Membership, :count).by(1)

        expect(response).to have_http_status(:created)

        json = response.parsed_body
        expect(json["status"]).to eq("ok")
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("rahul@leadflow.ai")
        expect(json["organization"]["name"]).to eq("Acme Estates")
        expect(json["organization"]["slug"]).to eq("acme-estates")
        expect(json["role"]).to eq("owner")

        membership = Membership.last
        expect(membership.role).to eq("owner")
        expect(membership.user.email).to eq("rahul@leadflow.ai")
        expect(membership.organization.name).to eq("Acme Estates")
      end
    end

    context "with duplicate email" do
      before { create(:user, email: "rahul@leadflow.ai") }

      let(:duplicate_params) do
        {
          user: {
            name: "Duplicate Rahul",
            email: "rahul@leadflow.ai",
            password: "password123"
          },
          organization: {
            name: "Another Org"
          }
        }
      end

      it "returns 422 Unprocessable Entity and does not create an orphaned organization" do
        expect do
          post "/api/v1/auth/signup", params: duplicate_params, as: :json
        end.not_to change(Organization, :count)

        expect(response).to have_http_status(422)
        json = response.parsed_body
        expect(json["error"]).to eq("Signup failed")
        expect(json["details"]).to include("Email has already been taken")
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "agent@leadflow.ai", password: "password123") }
    let!(:org) { create(:organization, name: "Skyline Realty") }
    let!(:membership) { create(:membership, user: user, organization: org, role: "salesperson") }

    context "with valid credentials" do
      it "returns 200 OK with token and user/organization context" do
        post "/api/v1/auth/login", params: { email: "agent@leadflow.ai", password: "password123" }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["status"]).to eq("ok")
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("agent@leadflow.ai")
        expect(json["organization"]["name"]).to eq("Skyline Realty")
        expect(json["role"]).to eq("salesperson")
      end
    end

    context "with incorrect password" do
      it "returns 401 Unauthorized" do
        post "/api/v1/auth/login", params: { email: "agent@leadflow.ai", password: "wrongpassword" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json["error"]).to eq("Invalid email or password")
      end
    end

    context "when user has no organization membership" do
      let!(:unattached_user) { create(:user, email: "solo@leadflow.ai", password: "password123") }

      it "returns 401 with no membership error" do
        post "/api/v1/auth/login", params: { email: "solo@leadflow.ai", password: "password123" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json["error"]).to include("No organization membership")
      end
    end
  end

  describe "POST /api/v1/auth/logout" do
    it "returns 200 OK acknowledging session end" do
      post "/api/v1/auth/logout"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["status"]).to eq("ok")
      expect(json["message"]).to eq("Logged out successfully")
    end
  end
end
