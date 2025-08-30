class PdfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.attached?
    
    unless value.content_type == 'application/pdf'
      record.errors.add(attribute, 'must be a PDF file')
    end
    
    if value.byte_size > 10.megabytes
      record.errors.add(attribute, 'must be less than 10MB')
    end
    
    # Basic PDF header check
    value.open do |file|
      unless file.read(4) == '%PDF'
        record.errors.add(attribute, 'is not a valid PDF file')
      end
    end
  end
end