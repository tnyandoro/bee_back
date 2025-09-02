class CreateMissingTicketSequences < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      Organization.find_each do |org|
        %w[inc prb req].each do |type|
          sequence_name = "tickets_#{type}_organization_#{org.id}_seq"
          execute <<-SQL
            CREATE SEQUENCE IF NOT EXISTS #{sequence_name};
          SQL
        end
      end
    end
  end

  def down
    safety_assured do
      Organization.find_each do |org|
        %w[inc prb req].each do |type|
          sequence_name = "tickets_#{type}_organization_#{org.id}_seq"
          execute <<-SQL
            DROP SEQUENCE IF EXISTS #{sequence_name};
          SQL
        end
      end
    end
  end
end