class Problem < ApplicationRecord
  belongs_to :ticket
  validates :description, presence: true
end
