class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :message, presence: true
  validates :user, presence: true
  validates :organization, presence: true
end
