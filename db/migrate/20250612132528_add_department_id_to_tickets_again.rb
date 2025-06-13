# frozen_string_literal: true
class AddDepartmentIdToTicketsAgain < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    safety_assured do
      add_reference :tickets, :department, foreign_key: true, null: true, index: true
    end
  end
end