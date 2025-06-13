class FixUsersSchema < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # Create departments table only if it doesn't exist
    unless table_exists?(:departments)
      create_table :departments do |t|
        t.string :name, null: false
        t.references :organization, null: false, foreign_key: true
        t.timestamps
      end
    end

    # Add department_id column if not already added
    unless column_exists?(:users, :department_id)
      add_column :users, :department_id, :bigint, null: true, index: { algorithm: :concurrently }
    end

    # Set NOT NULL constraints (handle null values first)
    safety_assured do
      # Set default values for null columns
      execute <<-SQL
        UPDATE users
        SET email = 'unknown_' || id || '@example.com'
        WHERE email IS NULL;
      SQL
      execute <<-SQL
        UPDATE users
        SET name = 'Unknown_' || id
        WHERE name IS NULL;
      SQL
      execute <<-SQL
        UPDATE users
        SET username = 'unknown_' || id
        WHERE username IS NULL;
      SQL
      execute <<-SQL
        UPDATE users
        SET role = 0
        WHERE role IS NULL;
      SQL

      # Add NOT NULL constraints if not already set
      change_column_null :users, :email, false unless column_has_null_constraint?(:users, :email)
      change_column_null :users, :name, false unless column_has_null_constraint?(:users, :name)
      change_column_null :users, :username, false unless column_has_null_constraint?(:users, :username)
      change_column_null :users, :role, false unless column_has_null_constraint?(:users, :role)
      change_column_default :users, :role, 0 unless column_has_default?(:users, :role, 0)
    end

    # Migrate department (string) data to departments table if department column exists
    if column_exists?(:users, :department)
      safety_assured do
        # Create departments for unique department names not already in departments
        execute <<-SQL
          INSERT INTO departments (name, organization_id, created_at, updated_at)
          SELECT DISTINCT u.department, u.organization_id, NOW(), NOW()
          FROM users u
          LEFT JOIN departments d ON d.name = u.department
          WHERE u.department IS NOT NULL AND u.department != '' AND d.id IS NULL;
        SQL

        # Update users.department_id based on department name
        execute <<-SQL
          UPDATE users
          SET department_id = d.id
          FROM departments d
          WHERE users.department = d.name
          AND users.department IS NOT NULL;
        SQL

        # Remove old department column
        remove_column :users, :department, :string
      end
    end
  end

  private

  def column_has_null_constraint?(table, column)
    result = execute <<-SQL
      SELECT is_nullable
      FROM information_schema.columns
      WHERE table_name = '#{table}' AND column_name = '#{column}';
    SQL
    result.first['is_nullable'] == 'NO'
  end

  def column_has_default?(table, column, default_value)
    result = execute <<-SQL
      SELECT column_default
      FROM information_schema.columns
      WHERE table_name = '#{table}' AND column_name = '#{column}';
    SQL
    result.first['column_default'] == default_value.to_s
  end
end