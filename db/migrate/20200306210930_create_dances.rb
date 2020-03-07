class CreateDances < ActiveRecord::Migration[5.0]
  def up
    create_table :dances do |t|
      t.references :performance
      t.references :dancer
    end

    create_table :dancers do |t|
      t.string :name
    end

    create_table :performances do |t|
      t.string :name
      t.references :act
    end

    create_table :acts do |t|
      t.integer :number
      t.references :schedule
    end

    create_table :schedules do |t|
      t.string :filename
    end
  end
end
