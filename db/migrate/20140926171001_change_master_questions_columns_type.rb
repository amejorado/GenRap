class ChangeMasterQuestionsColumnsType < ActiveRecord::Migration
  def up
    change_column :master_questions, :randomizer, :text
    change_column :master_questions, :solver, :text
  end

  def down
    change_column :master_questions, :randomizer, :string
    change_column :master_questions, :solver, :string
  end
end
