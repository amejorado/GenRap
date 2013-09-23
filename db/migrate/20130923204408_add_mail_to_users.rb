class AddMailToUsers < ActiveRecord::Migration
  def change
	  add_column :users, :mail, :string
	  remove_column :users, :email

  end
end
