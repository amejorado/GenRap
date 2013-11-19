class AddIdToCantake < ActiveRecord::Migration
  def change
    add_column :cantakes, :id, :primary_key
  end
end
