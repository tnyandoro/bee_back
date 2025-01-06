class Organization < ApplicationRecord
    validates :name, :email, presence: true
    validate :name, presence: true
    validates :subdomain, presence: true,  uniqueness: true
  
    before_validation :generate_subdomain, on: :create

    has_many :users, dependent: :destroy
    has_many :tickets, through: :users
    has_many :problems, through: :tickets

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
  
    def generate_subdomain
      self.subdomain ||= name.parameterize
    end
end
  