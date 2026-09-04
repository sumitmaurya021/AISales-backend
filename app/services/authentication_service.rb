# frozen_string_literal: true

class AuthenticationService
  def self.signup(user_params:, organization_params:)
    user = User.new(user_params)
    organization = Organization.new(organization_params)

    ActiveRecord::Base.transaction do
      unless user.save
        raise ActiveRecord::Rollback
      end

      unless organization.save
        raise ActiveRecord::Rollback
      end

      membership = Membership.create!(
        user: user,
        organization: organization,
        role: "owner"
      )

      token = JsonWebToken.encode(
        user_id: user.id,
        organization_id: organization.id
      )

      return {
        success: true,
        token: token,
        user: user,
        organization: organization,
        role: membership.role
      }
    end

    errors = user.errors.full_messages + organization.errors.full_messages
    { success: false, errors: errors.uniq }
  end

  def self.login(email:, password:, organization_id: nil)
    user = User.find_by("LOWER(email) = ?", email.to_s.downcase.strip)

    unless user&.authenticate(password)
      return { success: false, error: "Invalid email or password" }
    end

    membership = if organization_id.present?
                   user.memberships.includes(:organization).find_by(organization_id: organization_id)
    else
                   user.memberships.includes(:organization).first
    end

    unless membership
      return { success: false, error: "No organization membership found for this account" }
    end

    token = JsonWebToken.encode(
      user_id: user.id,
      organization_id: membership.organization_id
    )

    {
      success: true,
      token: token,
      user: user,
      organization: membership.organization,
      role: membership.role
    }
  end
end
