class AddUsernameUniqueIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # Remove any duplicate usernames within the same organization
    safety_assured do
      execute <<-SQL
        UPDATE users
        SET username = username || '_' || id
        WHERE id IN (
          SELECT id
          FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY organization_id, username ORDER BY id) AS rn
            FROM users
            WHERE username IS NOT NULL
          ) t
          WHERE rn > 1
        );
      SQL
    end

    # Add unique index concurrently
    add_index :users, [:username, :organization_id], unique: true, algorithm: :concurrently
  end
end