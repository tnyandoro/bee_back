# frozen_string_literal: true
class UserNotification < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :user, presence: true
  validates :organization, presence: true
  validates :message, presence: true
end