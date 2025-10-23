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
  
  after_create :log_organization_creation, :ensure_ticket_sequence!
  after_update :log_organization_update

  # Associations
  has_one_attached :logo
  has_many :business_hours, dependent: :destroy
  has_many :sla_policies, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :tickets, dependent: :destroy # Direct association with tickets
  has_many :problems, through: :tickets # Indirect association with problems through tickets
  has_many :teams, dependent: :destroy
  has_many :settings, class_name: "Setting", dependent: :destroy
  has_many :knowledgebase_entries, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  
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

  # SLA Configuration Methods
  def has_sla_configuration?
    sla_policies.exists? && business_hours.exists?
  end

  def setup_default_business_hours!
    return if business_hours.exists?
    
    transaction do
      # Monday to Friday, 8 AM to 5 PM
      (1..5).each do |day|
        business_hours.create!(
          day_of_week: day,
          start_time: '08:00',
          end_time: '17:00',
          active: true
        )
      end
    end
    
    Rails.logger.info "Default business hours created for organization: #{name}"
    true
  rescue => e
    Rails.logger.error "Failed to setup business hours for #{name}: #{e.message}"
    false
  end

  def setup_default_sla_policies!
    return if sla_policies.exists?
    
    transaction do
      sla_policies.create!(
        priority: 'critical',
        response_time: 120, # 2 hours for P1 as requested
        resolution_time: 240, # 4 hours  
        description: 'Critical priority tickets - 2 hour response SLA'
      )
      
      sla_policies.create!(
        priority: 'high', 
        response_time: 240, # 4 hours
        resolution_time: 480, # 8 hours
        description: 'High priority tickets'
      )
      
      sla_policies.create!(
        priority: 'medium',
        response_time: 480, # 8 hours
        resolution_time: 1440, # 24 hours
        description: 'Medium priority tickets'
      )
      
      sla_policies.create!(
        priority: 'low',
        response_time: 1440, # 24 hours
        resolution_time: 4320, # 72 hours
        description: 'Low priority tickets'
      )
    end
    
    Rails.logger.info "Default SLA policies created for organization: #{name}"
    true
  rescue => e
    Rails.logger.error "Failed to setup SLA policies for #{name}: #{e.message}"
    false
  end

  def setup_complete_sla_configuration!
    success = true
    success &= setup_default_business_hours!
    success &= setup_default_sla_policies!
    
    if success
      Rails.logger.info "Complete SLA configuration setup for organization: #{name}"
    else
      Rails.logger.error "Failed to complete SLA configuration setup for: #{name}"
    end
    
    success
  end

  # SLA Policy helpers
  def sla_policy_for_priority(priority)
    priority_mapping = {
      'p1' => 'critical',
      'p2' => 'high', 
      'p3' => 'medium',
      'p4' => 'low'
    }
    
    mapped_priority = priority_mapping[priority.to_s] || priority.to_s
    sla_policies.find_by(priority: mapped_priority)
  end

  def business_hours_for_day(day_of_week)
    business_hours.active.where(day_of_week: day_of_week).first
  end

  # Debugging/Status methods
  def sla_configuration_status
    {
      has_business_hours: business_hours.exists?,
      business_hours_count: business_hours.count,
      has_sla_policies: sla_policies.exists?,
      sla_policies_count: sla_policies.count,
      configured_priorities: sla_policies.pluck(:priority),
      is_fully_configured: has_sla_configuration?
    }
  end

  def ensure_ticket_sequence!
    sequence_name = "tickets_inc_organization_#{id}_seq"
    
    unless ActiveRecord::Base.connection.execute(
      "SELECT 1 FROM pg_class WHERE relname = '#{sequence_name}'"
    ).any?
      ActiveRecord::Base.connection.execute(
        "CREATE SEQUENCE #{sequence_name} START 1"
      )
      Rails.logger.info "Created ticket sequence for organization: #{name}"
    end
  end

  private

  # In Organization model
  def ensure_ticket_sequence!
    sequence_name = "tickets_inc_organization_#{id}_seq"
    
    unless ActiveRecord::Base.connection.execute(
      "SELECT 1 FROM pg_class WHERE relname = '#{sequence_name}'"
    ).any?
      ActiveRecord::Base.connection.execute(
        "CREATE SEQUENCE #{sequence_name} START 1"
      )
      Rails.logger.info "Created ticket sequence for organization: #{name}"
    end
  end

# Call this in an after_create callback or before ticket creation
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

  def log_organization_creation
    Rails.logger.info "Organization created: #{name} (ID: #{id})"
  end

  def log_organization_update
    Rails.logger.info "Organization updated: #{name} (ID: #{id})"
  end
end