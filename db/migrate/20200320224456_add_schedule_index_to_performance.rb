class AddScheduleIndexToPerformance < ActiveRecord::Migration[5.0]
  def change
    add_column :performances, :schedule_index, :integer
  end
end
