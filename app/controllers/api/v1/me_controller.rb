# frozen_string_literal: true

module Api
  module V1
    class MeController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: {
          user: {
            id: current_user.id,
            name: current_user.name,
            email: current_user.email,
            status: current_user.status
          },
          organization: {
            id: current_organization.id,
            name: current_organization.name,
            slug: current_organization.slug,
            timezone: current_organization.timezone,
            status: current_organization.status
          },
          role: current_membership.role,
          memberships: current_user.memberships.includes(:organization).map do |m|
            {
              organization_id: m.organization.id,
              organization_name: m.organization.name,
              organization_slug: m.organization.slug,
              role: m.role
            }
          end
        }, status: :ok
      end
    end
  end
end
