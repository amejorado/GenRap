class QuestionDeleted < ActiveRecord::Migration
  def change
	  add_column :master_questions, :questionDateDeleted, :date
  end
end
