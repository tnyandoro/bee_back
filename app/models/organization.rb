# frozen_string_literal: true

class Organization < ApplicationRecord
  # Validations
  validates :name, :email, presence: true
  validates :subdomain, presence: true, uniqueness: true

  # Ensure subdomain format
  validate :subdomain_format, on: :create

  # Ensure at least one admin user exists before saving the organization (adjusted this)
  validate :must_have_admin_user, on: :update

  # Callbacks
  before_validation :generate_subdomain, on: :create
  before_validation :normalize_subdomain

  # Associations
  has_many :business_hours, dependent: :destroy
  has_many :sla_policies, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :tickets, dependent: :destroy # Direct association with tickets
  has_many :problems, through: :tickets # Indirect association with problems through tickets
  has_many :teams, dependent: :destroy # Add this line if missing

  # Custom Methods
  def total_tickets
    tickets.count
  end

  def open_tickets
    tickets.where(status: 'open').count
  end

  def closed_tickets
    tickets.where(status: 'closed').count
  end

  def total_problems
    problems.count
  end

  def total_members
    users.count
  end

  private

  # Generate subdomain from the organization name if not provided
  def generate_subdomain
    self.subdomain ||= name.parameterize
  end

  # Ensure subdomain is lowercase
  def normalize_subdomain
    self.subdomain = subdomain.downcase if subdomain.present?
  end

  # Validate subdomain format
  def subdomain_format
    unless subdomain.match?(/\A[a-z0-9-]+\z/)
      errors.add(:subdomain, "can only contain lowercase letters, numbers, and hyphens")
    end
  end

  # Ensure at least one admin user exists before saving the organization (now on update)
  def must_have_admin_user
    return unless users.none? { |user| user.admin? }

    errors.add(:base, "An organization must have at least one admin user")
  end
end