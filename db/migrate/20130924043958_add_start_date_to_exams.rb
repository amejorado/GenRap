class AddStartDateToExams < ActiveRecord::Migration
  def change
	add_column :master_exams, :startdate, :date
	add_column :exams, :finishdate, :date
	add_column :master_exams, :finishdate, :date


  end
end
