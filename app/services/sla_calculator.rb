# frozen_string_literal: true

class SlaCalculator
  def initialize(ticket)
    @ticket = ticket
    @organization = ticket.organization
  end

  def calculate
    return unless can_calculate_sla?
    
    assign_sla_policy
    set_response_due_date
    set_resolution_due_date
    check_breaches
    @ticket.save!
  end

  private

  def can_calculate_sla?
    sla_policy.present? && business_hours.present?
  end

  def assign_sla_policy
    # Find SLA policy based on ticket priority
    policy = @organization.sla_policies.find_by(priority: @ticket.priority)
    @ticket.sla_policy = policy if policy
  end

  def sla_policy
    @sla_policy ||= @ticket.sla_policy || @organization.sla_policies.find_by(priority: @ticket.priority)
  end

  def business_hours
    @business_hours ||= @organization.business_hours
  end

  def set_response_due_date
    return unless sla_policy&.response_time
    
    @ticket.response_due_at = calculate_due_date(sla_policy.response_time)
  end

  def set_resolution_due_date
    return unless sla_policy&.resolution_time
    
    @ticket.resolution_due_at = calculate_due_date(sla_policy.resolution_time)
  end

  def calculate_due_date(minutes_to_add)
    current_time = @ticket.reported_at || @ticket.created_at
    remaining_minutes = minutes_to_add.to_i
    
    while remaining_minutes > 0
      # Get business hours for current day
      day_hours = business_hours.find_by(day_of_week: current_time.wday)
      
      unless day_hours
        # No business hours for this day, move to next day
        current_time = current_time.beginning_of_day + 1.day
        next
      end

      # Convert to same timezone for comparison
      start_time = time_on_date(current_time.to_date, day_hours.start_time)
      end_time = time_on_date(current_time.to_date, day_hours.end_time)
      
      # If current time is before business hours, move to start of business hours
      if current_time < start_time
        current_time = start_time
      end
      
      # If current time is after business hours, move to next day
      if current_time >= end_time
        current_time = current_time.beginning_of_day + 1.day
        next
      end
      
      # Calculate available minutes in current business day
      available_minutes = ((end_time - current_time) / 60).to_i
      
      if remaining_minutes <= available_minutes
        # Can finish within current business day
        current_time += remaining_minutes.minutes
        remaining_minutes = 0
      else
        # Use all available minutes and continue next business day
        remaining_minutes -= available_minutes
        current_time = current_time.beginning_of_day + 1.day
      end
    end
    
    current_time
  end

  def time_on_date(date, time)
    # Combine date with time of day
    Time.zone.parse("#{date} #{time.strftime('%H:%M:%S')}")
  end

  def check_breaches
    current_time = Time.current
    
    response_breached = @ticket.response_due_at && current_time > @ticket.response_due_at
    resolution_breached = @ticket.resolution_due_at && current_time > @ticket.resolution_due_at
    
    @ticket.sla_breached = response_breached || resolution_breached
  end
end