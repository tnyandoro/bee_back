# frozen_string_literal: true
class Department < ApplicationRecord
    belongs_to :organization
    has_many :users, dependent: :nullify
  
    validates :name, presence: true
    validates :organization_id, presence: true
end