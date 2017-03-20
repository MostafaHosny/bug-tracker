class CreateStates < ActiveRecord::Migration[5.0]
  def change
    create_table :states do |t|
      t.string :device
      t.string :os
      t.integer :memory
      t.integer :storage
 	  t.belongs_to :bug, index: true
      t.timestamps
    end
  end
end
