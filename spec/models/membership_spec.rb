# frozen_string_literal: true

require "rails_helper"

RSpec.describe Membership, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      membership = build(:membership)
      expect(membership).to be_valid
    end

    it "validates allowed role values" do
      valid_roles = %w[owner admin manager salesperson]
      valid_roles.each do |role|
        expect(build(:membership, role: role)).to be_valid
      end

      expect(build(:membership, role: "superadmin")).not_to be_valid
    end

    it "enforces uniqueness of user within same organization" do
      org = create(:organization)
      user = create(:user)
      create(:membership, organization: org, user: user)

      duplicate = build(:membership, organization: org, user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("is already a member of this organization")
    end

    it "allows same user in multiple different organizations" do
      user = create(:user)
      org1 = create(:organization)
      org2 = create(:organization)

      m1 = create(:membership, organization: org1, user: user, role: "owner")
      m2 = build(:membership, organization: org2, user: user, role: "salesperson")

      expect(m1).to be_valid
      expect(m2).to be_valid
    end
  end

  describe "role helper methods" do
    it "correctly identifies roles" do
      membership = build(:membership, role: "owner")
      expect(membership.owner?).to be true
      expect(membership.admin?).to be false
    end
  end
end
