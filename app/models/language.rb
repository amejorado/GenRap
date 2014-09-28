class Language < ActiveRecord::Base
  has_many :concepts, dependent: :destroy
  belongs_to :master_question
  belongs_to :master_exam
  belongs_to :question

  attr_accessible :name

  validates :name, presence: true, uniqueness: true
end
