class AddLockedToPerformance < ActiveRecord::Migration[5.0]
  def change
    add_column :performances, :locked, :boolean
  end
end
