class UpdateUserRolesToNewStructure < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Phase 1: Direct integer to integer mapping
    safety_assured do
      execute <<~SQL
        UPDATE users SET role = CASE
          WHEN role = 0 THEN 1   -- service_desk_agent → call_center_agent
          WHEN role = 1 THEN 3   -- level_1_2_support → assignee_lvl_1_2
          WHEN role = 2 THEN 2   -- team_leader → service_desk_tl (no change)
          WHEN role = 3 THEN 4   -- level_3_support → assignee_lvl_3
          WHEN role = 4 THEN 7   -- incident_manager (no change)
          WHEN role = 5 THEN 8   -- problem_manager (no change)
          WHEN role = 6 THEN 8   -- problem_coordinator → problem_manager
          WHEN role = 7 THEN 9   -- change_manager (no change)
          WHEN role = 8 THEN 9   -- change_coordinator → change_manager
          WHEN role = 9 THEN 10  -- department_manager (no change)
          WHEN role = 10 THEN 11 -- general_manager (no change)
          WHEN role = 11 THEN 14 -- system_admin (no change)
          WHEN role = 12 THEN 13 -- domain_admin (no change)
          ELSE role
        END
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL
        UPDATE users SET role = CASE
          WHEN role = 1 THEN 0   -- call_center_agent → service_desk_agent
          WHEN role = 3 THEN 1   -- assignee_lvl_1_2 → level_1_2_support
          WHEN role = 2 THEN 2   -- service_desk_tl → team_leader (no change)
          WHEN role = 4 THEN 3   -- assignee_lvl_3 → level_3_support
          WHEN role = 7 THEN 4   -- incident_manager (no change)
          WHEN role = 8 THEN 5   -- problem_manager (no change)
          WHEN role = 9 THEN 7   -- change_manager (no change)
          WHEN role = 10 THEN 9  -- department_manager (no change)
          WHEN role = 11 THEN 10 -- general_manager (no change)
          WHEN role = 14 THEN 11 -- system_admin (no change)
          WHEN role = 13 THEN 12 -- domain_admin (no change)
          ELSE role
        END
      SQL
    end
  end
end