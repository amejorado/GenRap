class AddColumnsExamDefinition < ActiveRecord::Migration

  def up
  	add_column :exam_definitions, :master_exam_id, :integer
  	add_column :exam_definitions, :master_question_id, :integer
  	add_column :exam_definitions, :questionNum, :integer
  	add_column :exam_definitions, :weight, :float
  
  end

  def down
  end
end
