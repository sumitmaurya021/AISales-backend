# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Health", type: :request do
  describe "GET /api/v1/health" do
    context "when all services are operational" do
      it "returns 200 OK with healthy status and service connections" do
        get "/api/v1/health"

        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json["status"]).to eq("ok")
        expect(json["version"]).to eq("1.0.0")
        expect(json["services"]["database"]).to eq("connected")
        expect(json["services"]["redis"]).to eq("connected")
        expect(json["timestamp"]).to be_present
      end
    end

    context "when database is unreachable" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(ActiveRecord::ConnectionNotEstablished)
      end

      it "returns 503 Service Unavailable with degraded status" do
        get "/api/v1/health"

        expect(response).to have_http_status(:service_unavailable)

        json = response.parsed_body
        expect(json["status"]).to eq("degraded")
        expect(json["services"]["database"]).to eq("unreachable")
      end
    end

    context "when Redis is unreachable" do
      before do
        allow($redis).to receive(:ping).and_raise(Redis::CannotConnectError)
      end

      it "returns 503 Service Unavailable with degraded status" do
        get "/api/v1/health"

        expect(response).to have_http_status(:service_unavailable)

        json = response.parsed_body
        expect(json["status"]).to eq("degraded")
        expect(json["services"]["redis"]).to eq("unreachable")
      end
    end
  end
end
