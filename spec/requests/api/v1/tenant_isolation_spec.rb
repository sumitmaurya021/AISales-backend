# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1 Multi-Tenancy & Tenant Isolation", type: :request do
  let!(:org_a) { create(:organization, name: "Organization Alpha") }
  let!(:org_b) { create(:organization, name: "Organization Beta") }

  let!(:user_a) { create(:user, email: "alpha_user@leadflow.ai") }
  let!(:user_b) { create(:user, email: "beta_user@leadflow.ai") }

  let!(:membership_a) { create(:membership, user: user_a, organization: org_a, role: "owner") }
  let!(:membership_b) { create(:membership, user: user_b, organization: org_b, role: "salesperson") }

  let(:token_a) { JsonWebToken.encode(user_id: user_a.id, organization_id: org_a.id) }
  let(:token_b) { JsonWebToken.encode(user_id: user_b.id, organization_id: org_b.id) }

  describe "Strict Tenant Isolation" do
    it "resolves Organization Alpha for user A and Organization Beta for user B" do
      get "/api/v1/me", headers: { "Authorization" => "Bearer #{token_a}" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["organization"]["id"]).to eq(org_a.id)

      get "/api/v1/me", headers: { "Authorization" => "Bearer #{token_b}" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["organization"]["id"]).to eq(org_b.id)
    end

    it "blocks user A from accessing Organization Beta via X-Organization-Id header" do
      get "/api/v1/me", headers: {
        "Authorization" => "Bearer #{token_a}",
        "X-Organization-Id" => org_b.id
      }

      expect(response).to have_http_status(:forbidden)
      json = response.parsed_body
      expect(json["error"]).to eq("Unauthorized access to requested organization")
    end

    context "when a user belongs to multiple organizations" do
      let!(:org_c) { create(:organization, name: "Organization Gamma") }
      let!(:membership_a_c) { create(:membership, user: user_a, organization: org_c, role: "salesperson") }

      it "allows switching to another legitimate membership via X-Organization-Id" do
        get "/api/v1/me", headers: {
          "Authorization" => "Bearer #{token_a}",
          "X-Organization-Id" => org_c.id
        }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["organization"]["id"]).to eq(org_c.id)
        expect(json["role"]).to eq("salesperson")
      end

      it "still rejects switching to Organization Beta where user A has no membership" do
        get "/api/v1/me", headers: {
          "Authorization" => "Bearer #{token_a}",
          "X-Organization-Id" => org_b.id
        }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user account status is suspended" do
      before { user_a.update!(status: "suspended") }

      it "rejects access with 401 Unauthorized" do
        get "/api/v1/me", headers: { "Authorization" => "Bearer #{token_a}" }

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json["error"]).to eq("User account is inactive or not found")
      end
    end
  end
end
