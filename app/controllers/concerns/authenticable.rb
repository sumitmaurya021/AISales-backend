# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user, :current_organization, :current_membership
  end

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    unless token
      render json: { error: "Authentication token required" }, status: :unauthorized
      return
    end

    payload = JsonWebToken.decode(token)
    unless payload && payload[:user_id]
      render json: { error: "Invalid or expired authentication token" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: payload[:user_id])
    unless @current_user && @current_user.status == "active"
      render json: { error: "User account is inactive or not found" }, status: :unauthorized
      return
    end

    target_org_id = request.headers["X-Organization-Id"].presence || payload[:organization_id]
    @current_membership = if target_org_id
                            @current_user.memberships.includes(:organization).find_by(organization_id: target_org_id)
    else
                            @current_user.memberships.includes(:organization).first
    end

    # If an explicit X-Organization-Id was provided that user has no access to, reject immediately
    if request.headers["X-Organization-Id"].present? && @current_membership.nil?
      render json: { error: "Unauthorized access to requested organization" }, status: :forbidden
      return
    end

    unless @current_membership
      render json: { error: "No organization membership found for this user" }, status: :forbidden
      return
    end

    @current_organization = @current_membership.organization
  end

  def authorize_role!(*allowed_roles)
    required_roles = allowed_roles.flatten.map(&:to_s)
    user_role = @current_membership&.role

    unless required_roles.include?(user_role)
      render json: { error: "You do not have permission to perform this action" }, status: :forbidden
    end
  end
end
