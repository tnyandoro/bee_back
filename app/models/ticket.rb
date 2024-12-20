class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum status: { open: 0, assigned: 1, escalated: 2, closed: 3, suspended: 4 }
  validates :title, :description, presence: true
end
