# app/models/business_hour.rb
class BusinessHour < ApplicationRecord
    belongs_to :organization
  
    enum day_of_week: {
      monday: 0,
      tuesday: 1,
      wednesday: 2,
      thursday: 3,
      friday: 4,
      saturday: 5,
      sunday: 6
    }
  
    validates :start_time, :end_time, presence: true
    validates :day_of_week, presence: true, uniqueness: { scope: :organization_id }
  
    def working_hours
      (start_time.seconds_since_midnight..end_time.seconds_since_midnight)
    end
  end