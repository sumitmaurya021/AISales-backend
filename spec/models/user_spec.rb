# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "validates presence of name" do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "validates presence and format of email" do
      invalid_user = build(:user, email: "invalid-email")
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors[:email]).to include("is invalid")
    end

    it "enforces case-insensitive email uniqueness" do
      create(:user, email: "rahul@example.com")
      duplicate = build(:user, email: "RAHUL@EXAMPLE.COM")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "validates password length minimum of 6 characters" do
      user = build(:user, password: "123", password_confirmation: "123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "downcases email before saving" do
      user = create(:user, email: "TEST@EXAMPLE.COM")
      expect(user.reload.email).to eq("test@example.com")
    end
  end

  describe "associations" do
    it "has many memberships and organizations" do
      user = create(:user)
      org = create(:organization)
      create(:membership, organization: org, user: user)

      expect(user.memberships.count).to eq(1)
      expect(user.organizations).to include(org)
    end
  end
end
