class AddStartDateToMasterExams < ActiveRecord::Migration
  def change
	add_column :master_exams, :stardate, :date
  end
end
