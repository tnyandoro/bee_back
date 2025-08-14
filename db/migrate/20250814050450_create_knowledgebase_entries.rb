class CreateKnowledgebaseEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :knowledgebase_entries do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :issue
      t.text :description
      t.text :troubleshooting_steps
      t.string :assigned_group
      t.text :resolution_steps

      t.timestamps
    end
  end
end
