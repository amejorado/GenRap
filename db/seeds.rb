# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)
#
admin = User.create( :fname => 'Admin', :lname => 'Root', :password => 'qwerty123', :username => 'admin', :mail => 'admin@root.com')

admin.utype = 2
admin.save

langs = ['C++', 'C#', 'Java']
concepts = ['Calculos Basicos','Funciones Predefinidas','Funciones Definidas','Decisiones Simples','Decisiones Complejas','Decisiones Anidades','Ciclos Fijos','Ciclos Variables','Ciclos Anidados', 'If y Ciclos', 'Arreglos', 'Matrices']
subconcepts = ['Evaluacion']
for lang_name in langs
	lang = Language.create( :name => lang_name )
	lang.save
	for concept_name in concepts
		concept = Concept.create(
			{:name => concept_name, :language => lang},
			 :without_protection => true
		 )
		concept.save
		for subconcept_name in subconcepts
			subconcept = SubConcept.create(
				{:name => subconcept_name, :concept => concept},
				 :without_protection => true
			 ).save
		end
	end
end

