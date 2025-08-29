class BusinessHour < ApplicationRecord
  belongs_to :organization
  
  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
  validates :day_of_week, uniqueness: { scope: :organization_id }
  
  validate :end_time_after_start_time
  
  scope :active, -> { where(active: true) }
  scope :for_day, ->(day) { where(day_of_week: day) }
  
  def self.day_names
    %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  end
  
  def day_name
    self.class.day_names[day_of_week]
  end
  
  private
  
  def end_time_after_start_time
    return unless start_time && end_time
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end