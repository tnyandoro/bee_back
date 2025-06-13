# frozen_string_literal: true
class CreateTicketNumberSequences < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      # Create sequences for each existing organization and ticket type
      execute <<-SQL
        DO $$
        DECLARE
          org_id integer;
        BEGIN
          FOR org_id IN SELECT id FROM organizations
          LOOP
            -- Create sequences for Incident, Request, Problem
            EXECUTE format('CREATE SEQUENCE tickets_inc_organization_%s_seq START 1', org_id);
            EXECUTE format('CREATE SEQUENCE tickets_req_organization_%s_seq START 1', org_id);
            EXECUTE format('CREATE SEQUENCE tickets_prb_organization_%s_seq START 1', org_id);
          END LOOP;
        END $$;
      SQL
    end
  end

  def down
    safety_assured do
      # Drop sequences for each organization
      execute <<-SQL
        DO $$
        DECLARE
          org_id integer;
        BEGIN
          FOR org_id IN SELECT id FROM organizations
          LOOP
            EXECUTE format('DROP SEQUENCE IF EXISTS tickets_inc_organization_%s_seq', org_id);
            EXECUTE format('DROP SEQUENCE IF EXISTS tickets_req_organization_%s_seq', org_id);
            EXECUTE format('DROP SEQUENCE IF EXISTS tickets_prb_organization_%s_seq', org_id);
          END LOOP;
        END $$;
      SQL
    end
  end
end