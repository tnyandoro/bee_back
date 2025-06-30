class CreateTicketsPrbOrganization4Seq < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute <<~SQL
        CREATE SEQUENCE IF NOT EXISTS tickets_prb_organization_4_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL
        DROP SEQUENCE IF EXISTS tickets_prb_organization_4_seq;
      SQL
    end
  end
end
