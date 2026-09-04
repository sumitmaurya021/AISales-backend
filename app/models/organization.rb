# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :status, inclusion: { in: %w[active suspended archived] }
  validates :timezone, presence: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?
    return if name.blank?

    base_slug = name.parameterize
    base_slug = "org" if base_slug.blank?
    candidate = base_slug
    counter = 1

    while Organization.exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end
