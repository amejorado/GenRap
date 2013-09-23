class AddEmailToUsers < ActiveRecord::Migration
  def change
  	remove_column :users , :email
  	add_column :users , :mail, :string
  end
end
