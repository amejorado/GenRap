class CreateExamDefinitions < ActiveRecord::Migration
  def change
    create_table :exam_definitions do |t|

      t.timestamps
    end
  end
end
