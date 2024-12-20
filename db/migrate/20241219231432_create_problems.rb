class CreateProblems < ActiveRecord::Migration[7.1]
  def change
    create_table :problems do |t|
      t.text :description
      t.references :ticket, null: false, foreign_key: true

      t.timestamps
    end
  end
end
