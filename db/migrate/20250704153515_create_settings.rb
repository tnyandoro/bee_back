class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :key
      t.jsonb :value

      t.timestamps
    end
  end
end
