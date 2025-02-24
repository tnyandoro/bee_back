# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :notifiable, polymorphic: true, optional: true # Already correct

  validates :user, presence: true
  validates :organization, presence: true
  validates :message, presence: true
end