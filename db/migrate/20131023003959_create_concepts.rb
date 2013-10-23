class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string :name
      t.integer :language_id

      t.timestamps
    end
  end
end
