# frozen_string_literal: true

class Organization < ApplicationRecord
  # Validations
  validates :name, :email, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }

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

  def total_agents
    users.where(role: :agent).count
  end

  def total_team_leads
    users.where(role: :team_lead).count
  end

  def average_ticket_resolution_time
    tickets.closed.average(:resolution_time) || 0
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
    if users.reject(&:marked_for_destruction?).none?(&:admin?)
      errors.add(:base, "An organization must have at least one admin user")
    end
  end

  # Logging
  after_create :log_organization_creation
  after_update :log_organization_update

  def log_organization_creation
    Rails.logger.info "Organization created: #{name} (ID: #{id})"
  end

  def log_organization_update
    Rails.logger.info "Organization updated: #{name} (ID: #{id})"
  end
end
