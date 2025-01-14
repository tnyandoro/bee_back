class MakeFieldsRequiredInTickets < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tickets, :team_id, false
    change_column_null :tickets, :reported_at, false
    change_column_null :tickets, :category, false
    change_column_null :tickets, :caller_name, false
    change_column_null :tickets, :caller_surname, false
    change_column_null :tickets, :caller_email, false
    change_column_null :tickets, :caller_phone, false
    change_column_null :tickets, :customer, false
    change_column_null :tickets, :source, false
  end
end