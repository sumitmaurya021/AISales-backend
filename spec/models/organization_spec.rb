# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      org = build(:organization, name: "Skyline Realty")
      expect(org).to be_valid
    end

    it "validates presence of name" do
      org = build(:organization, name: nil)
      expect(org).not_to be_valid
      expect(org.errors[:name]).to include("can't be blank")
    end

    it "auto-generates unique slug on creation" do
      org1 = create(:organization, name: "Apex Properties")
      expect(org1.slug).to eq("apex-properties")

      org2 = create(:organization, name: "Apex Properties")
      expect(org2.slug).to eq("apex-properties-1")
    end

    it "validates status inclusion" do
      org = build(:organization, status: "invalid_status")
      expect(org).not_to be_valid
      expect(org.errors[:status]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "has many memberships and users" do
      org = create(:organization)
      user = create(:user)
      create(:membership, organization: org, user: user)

      expect(org.memberships.count).to eq(1)
      expect(org.users).to include(user)
    end
  end
end
