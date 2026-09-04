# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Org #{n}" }
    timezone { "UTC" }
    status { "active" }
  end
end
