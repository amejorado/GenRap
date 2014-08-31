class Cantake < ActiveRecord::Base
  belongs_to :master_exam
  belongs_to :user
  belongs_to :exams

  # validates :master_exam, :presence => true
  validates :user, presence: true

  attr_accessible :master_exam, :user, :user_id
end
