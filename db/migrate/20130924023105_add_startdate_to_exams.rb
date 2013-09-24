class AddStartdateToExams < ActiveRecord::Migration
  def change
	  add_column :exams, :startdate, :date

	
  end
end
