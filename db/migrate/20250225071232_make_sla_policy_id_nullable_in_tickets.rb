class MakeSlaPolicyIdNullableInTickets < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tickets, :sla_policy_id, true
  end
end