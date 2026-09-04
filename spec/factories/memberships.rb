# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    organization
    user
    role { "salesperson" }

    trait :owner do
      role { "owner" }
    end

    trait :admin do
      role { "admin" }
    end

    trait :manager do
      role { "manager" }
    end
  end
end
