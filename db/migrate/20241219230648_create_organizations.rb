class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :address
      t.string :email
      t.string :web_address
      t.string :subdomain

      t.timestamps
    end
    add_index :organizations, :subdomain, unique: true
  end
end
