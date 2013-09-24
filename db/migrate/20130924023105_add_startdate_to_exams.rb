class AddStartdateToExams < ActiveRecord::Migration
  def change
	  add_column :exams, :startdate, :date
	  add_column :exams, :finishdate, :date
	
  end
end
