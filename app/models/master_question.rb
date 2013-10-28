#encoding: utf-8
class MasterQuestion < ActiveRecord::Base
  has_many :master_exams, :through => :exam_definition
  has_many :questions
  has_many :exam_definition
  belongs_to :language
  belongs_to :concept
  belongs_to :sub_concept, :foreign_key => 'subconcept_id'


  validates :concept_id,	:presence => true
  validates :inquiry,	:presence => true
  validates :language_id,	:presence => true
  validates :randomizer, :presence => true
  validates :solver,	:presence => true
  validates :subconcept_id, :presence => true
  validates :borrado, :presence => true

  attr_accessible :concept, :inquiry, :language, :randomizer, :solver, :subconcept, :borrado, :questionDateDeleted, :concept_id, :language_id, :subconcept_id

  def self.all_languages
    select("DISTINCT language")
  end

end
