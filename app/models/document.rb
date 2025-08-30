# frozen_string_literal: true
class Document < ApplicationRecord
    belongs_to :tenant
    has_one_attached :pdf_file
    
    validates :pdf_file, content_type: ['application/pdf']
end