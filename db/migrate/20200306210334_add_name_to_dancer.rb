class AddNameToDancer < ActiveRecord::Migration[5.0]
  def change
    add_column :dancers, :name, :string
  end
end
