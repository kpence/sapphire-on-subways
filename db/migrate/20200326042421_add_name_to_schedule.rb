class AddNameToSchedule < ActiveRecord::Migration[5.0]
  def change
    add_column :schedules, :name, :string
  end
end
