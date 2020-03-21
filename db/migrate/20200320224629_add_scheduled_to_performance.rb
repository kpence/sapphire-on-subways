class AddScheduledToPerformance < ActiveRecord::Migration[5.0]
  def change
    add_column :performances, :scheduled, :boolean
  end
end
