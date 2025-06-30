# config/initializers/ensure_sequences.rb

Rails.application.config.after_initialize do
    # Only run in production and when database is available
    if Rails.env.production? && ActiveRecord::Base.connection.table_exists?('organizations')
      begin
        Rails.logger.info 'Checking for required sequences...'
        
        Organization.find_each do |org|
          sequence_name = "tickets_prb_organization_#{org.id}_seq"
          
          unless sequence_exists?(sequence_name)
            create_sequence(sequence_name)
            Rails.logger.info "Created missing sequence: #{sequence_name}"
          end
        end
        
        Rails.logger.info 'Sequence check completed.'
      rescue => e
        Rails.logger.error "Error during sequence initialization: #{e.message}"
        # Don't crash the app, just log the error
      end
    end
end
  
def sequence_exists?(sequence_name)
    result = ActiveRecord::Base.connection.execute(
      "SELECT 1 FROM information_schema.sequences WHERE sequence_name = '#{sequence_name}' LIMIT 1"
    )
    result.any?
rescue
    false
end
  
def create_sequence(sequence_name)
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE SEQUENCE IF NOT EXISTS #{sequence_name}
      START WITH 1
      INCREMENT BY 1
      NO MINVALUE
      NO MAXVALUE
      CACHE 1;
    SQL
rescue => e
    Rails.logger.error "Failed to create sequence #{sequence_name}: #{e.message}"
    raise e
end
