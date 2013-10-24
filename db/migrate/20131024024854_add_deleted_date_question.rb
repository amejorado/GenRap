class AddDeletedDateQuestion < ActiveRecord::Migration
  def change
	  add_column :master_questions, :dateDeletedQuestion, :date
  end
end
