# frozen_string_literal: true

class Membership < ApplicationRecord
  ROLES = %w[owner admin manager salesperson].freeze

  belongs_to :organization
  belongs_to :user

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :organization_id, message: "is already a member of this organization" }

  def owner?
    role == "owner"
  end

  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def salesperson?
    role == "salesperson"
  end
end
