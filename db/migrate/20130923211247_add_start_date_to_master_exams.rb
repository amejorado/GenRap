class AddStartDateToMasterExams < ActiveRecord::Migration
  def change
	add_column :master_exams, :startdate, :date
  end
end
