class SubConcept < ActiveRecord::Base
  belongs_to :concept

  validates :name, :presence => true
  validates :concept, :presence => true
  
  attr_accessible :name, :concept_id
end
