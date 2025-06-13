# frozen_string_literal: true
class Department < ApplicationRecord
    belongs_to :organization
    has_many :users, dependent: :nullify
    has_many :tickets, dependent: :nullify  # ✅ Add this line
  
    validates :name, presence: true
    validates :organization_id, presence: true
end
