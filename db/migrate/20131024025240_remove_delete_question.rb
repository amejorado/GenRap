class RemoveDeleteQuestion < ActiveRecord::Migration
  def change
    remove_column :master_questions, :dateDeletedQuestion, :date
  end
end
