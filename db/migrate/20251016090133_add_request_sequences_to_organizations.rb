class AddRequestSequencesToOrganizations < ActiveRecord::Migration[7.1]
  def up
    Organization.find_each do |org|
      ['req', 'prb', 'chg'].each do |type|
        sequence_name = "tickets_#{type}_organization_#{org.id}_seq"
        
        safety_assured do
          execute <<-SQL
            CREATE SEQUENCE IF NOT EXISTS #{sequence_name} START 1
          SQL
        end
      end
    end
  end

  def down
    Organization.find_each do |org|
      ['req', 'prb', 'chg'].each do |type|
        sequence_name = "tickets_#{type}_organization_#{org.id}_seq"
        
        safety_assured do
          execute <<-SQL
            DROP SEQUENCE IF EXISTS #{sequence_name}
          SQL
        end
      end
    end
  end
end