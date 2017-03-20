class AddIndexToBugs < ActiveRecord::Migration[5.0]
  def change
  	add_index(:bugs, [:application_token, :number], unique: true)
  end
end
