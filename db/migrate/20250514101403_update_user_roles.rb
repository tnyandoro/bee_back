class UpdateUserRoles < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute <<-SQL
        UPDATE users
        SET role = CASE role
          WHEN 0 THEN 11 -- admin -> system_admin
          WHEN 1 THEN 0  -- super_user -> service_desk_agent
          WHEN 2 THEN 2  -- team_lead -> team_leader
          WHEN 3 THEN 0  -- agent -> service_desk_agent
          WHEN 4 THEN 0  -- viewer -> service_desk_agent
          WHEN 5 THEN 9  -- department_manager -> department_manager
          WHEN 6 THEN 10 -- general_manager -> general_manager
          WHEN 7 THEN 12 -- domain_admin -> domain_admin
          ELSE 0  -- default to service_desk_agent
        END
        WHERE role IS NOT NULL;
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        UPDATE users
        SET role = CASE role
          WHEN 11 THEN 0 -- system_admin -> admin
          WHEN 2 THEN 2  -- team_leader -> team_lead
          WHEN 0 THEN 3  -- service_desk_agent -> agent
          WHEN 9 THEN 5  -- department_manager -> department_manager
          WHEN 10 THEN 6 -- general_manager -> general_manager
          WHEN 12 THEN 7 -- domain_admin -> domain_admin
          ELSE 3  -- default to agent
        END
        WHERE role IS NOT NULL;
      SQL
    end
  end
end