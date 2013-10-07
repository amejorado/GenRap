class CampoBorrar < ActiveRecord::Migration
	def change
		add_column :master_questions, :borrado, :int
	end
end