class CreateExcelFormats < ActiveRecord::Migration
  def change
    create_table :excel_formats do |t|
      t.string :usuario
      t.integer :intentos
      t.float :resultados

      t.timestamps
    end
  end
end
