# frozen_string_literal: true

module Api
  module V1
    class HealthController < ApplicationController
      def show
        db_status = check_database
        redis_status = check_redis

        healthy = (db_status == "connected") && (redis_status == "connected")

        render json: {
          status: healthy ? "ok" : "degraded",
          timestamp: Time.current.utc.iso8601,
          version: "1.0.0",
          services: {
            database: db_status,
            redis: redis_status
          }
        }, status: healthy ? :ok : :service_unavailable
      end

      private

      def check_database
        ActiveRecord::Base.connection.execute("SELECT 1")
        "connected"
      rescue StandardError => e
        Rails.logger.error("Database health check failed: #{e.message}")
        "unreachable"
      end

      def check_redis
        $redis.ping == "PONG" ? "connected" : "unreachable"
      rescue StandardError => e
        Rails.logger.error("Redis health check failed: #{e.message}")
        "unreachable"
      end
    end
  end
end
