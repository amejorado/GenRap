class ChangeQuestionsConcepts < ActiveRecord::Migration
  def change
	rename_column :master_questions, :language, :language_id
	rename_column :master_questions, :concept, :concept_id	
	rename_column :master_questions, :subconcept, :subconcept_id
  end
end
