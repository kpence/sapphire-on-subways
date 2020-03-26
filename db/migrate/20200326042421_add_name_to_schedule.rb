class AddNameToSchedule < ActiveRecord::Migration[5.0]
  def change
    add_column :schedules, :name, :String
  end
end
