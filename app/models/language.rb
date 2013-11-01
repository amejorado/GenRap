class Language < ActiveRecord::Base
  belongs_to :master_question	
  belongs_to :master_exam
  belongs_to :question
	  
  attr_accessible :name
end
