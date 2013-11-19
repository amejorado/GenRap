class AddGroupToCanTakes < ActiveRecord::Migration
  def change
  	add_column :cantakes, :group_id, :integer
  end
end
