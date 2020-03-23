class AddPositionToPerformances < ActiveRecord::Migration[5.0]
  def change
    add_column :performances, :position, :integer
  end
end
