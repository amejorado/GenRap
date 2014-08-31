class Concept < ActiveRecord::Base
  has_many :sub_concepts, dependent: :destroy
  has_many :master_questions, dependent: :destroy
  belongs_to :language

  validates :name, presence: true
  validates :language, presence: true

  attr_accessible :name, :language_id
end
