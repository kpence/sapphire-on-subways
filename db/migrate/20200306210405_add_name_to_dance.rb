class AddNameToDance < ActiveRecord::Migration[5.0]
  def change
    add_column :dances, :name, :string
  end
end
