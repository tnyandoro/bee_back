# frozen_string_literal: true
class Document < ApplicationRecord
  include TenantScoped

  has_one_attached :pdf_file do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [200, 200]
  end

  validates :pdf_file, presence: true
#   validates :pdf_file, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
# commented out above line to allow all file types for now
  before_save :set_file_path

  private

  def set_file_path
    return unless pdf_file.attached?
    self.file_path = "tenants/#{tenant.id}/documents/#{id}"
  end
end