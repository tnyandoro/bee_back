class AddLastNameToUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :users, :last_name, :string
    
    # Split existing names for users who have spaces in their name
    User.find_each do |user|
      if user.name.present? && user.name.include?(' ')
        name_parts = user.name.split(' ')
        first_name = name_parts.first
        last_name = name_parts[1..-1].join(' ')
        user.update_columns(name: first_name, last_name: last_name)
      end
    end
    
    # Optional: Add index for searching by last name
    # add_index :users, :last_name
  end
  
  def down
    # Before removing last_name, combine names back for users who have both
    User.where.not(last_name: [nil, '']).find_each do |user|
      full_name = "#{user.name} #{user.last_name}".strip
      user.update_columns(name: full_name)
    end
    
    remove_column :users, :last_name
  end
end