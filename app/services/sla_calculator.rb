# Service Object to calculate SLA for a ticket
# Frozen string literal: true

class SlaCalculator
    def initialize(ticket)
      @ticket = ticket
      @organization = ticket.organization
    end
  
    def calculate
      set_response_due_date
      set_resolution_due_date
      check_breaches
    end
  
    private
  
    def set_response_due_date
      response_time = @ticket.sla_policy.response_time
      @ticket.response_due_at = calculate_due_date(response_time)
    end
  
    def set_resolution_due_date
      resolution_time = @ticket.sla_policy.resolution_time
      @ticket.resolution_due_at = calculate_due_date(resolution_time)
    end
  
    def calculate_due_date(minutes)
      current_time = @ticket.reported_at
      business_hours = @organization.business_hours
      minutes.to_i.times do
        current_time += 1.minute
        current_time = next_business_day(current_time) unless business_hour?(current_time, business_hours)
      end
      current_time
    end
  
    def business_hour?(time, business_hours)
      day = time.wday
      hours = business_hours.find_by(day_of_week: day)
      return false unless hours
  
      time.strftime('%H:%M').between?(hours.start_time.strftime('%H:%M'), hours.end_time.strftime('%H:%M'))
    end
  
    def next_business_day(time)
      loop do
        time += 1.day
        break if business_hour?(time.beginning_of_day, @organization.business_hours)
      end
      time.beginning_of_work_day
    end
  
    def check_breaches
      @ticket.sla_breached = Time.current > @ticket.response_due_at || Time.current > @ticket.resolution_due_at
    end
  end
