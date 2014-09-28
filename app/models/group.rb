class Group < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :users

  attr_accessible :name, :user, :user_ids, :id, :user_id

  validates :name,  presence: true
  validates :user,  presence: true
end
