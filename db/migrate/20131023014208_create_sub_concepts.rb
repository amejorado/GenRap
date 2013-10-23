class CreateSubConcepts < ActiveRecord::Migration
  def change
    create_table :sub_concepts do |t|
      t.string :name
      t.integer :concept_id

      t.timestamps
    end
  end
end
