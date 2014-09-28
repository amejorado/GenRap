# encoding: utf-8

class User < ActiveRecord::Base
  USER_TYPES = [STUDENT = 0, PROFESSOR = 1, ADMIN = 2]
  has_secure_password
  attr_accessible :fname, :lname, :password, :username, :email,
                  :password_confirmation, :group_ids, :mail, :utype

  scope :professors, -> { where(utype: PROFESSOR) }
  scope :students, -> { where(utype: STUDENT) }

  has_and_belongs_to_many :groups
  has_many :groups_owned, class_name: 'Group', inverse_of: :user,
                          dependent: :destroy
  has_many :cantakes, dependent: :destroy
  has_many :master_exams, through: :cantakes
  has_many :exams, dependent: :destroy

  validates :username,  presence: true,
                        uniqueness: true
  validates_uniqueness_of :username, message: 'El usuario no es unico'

  validates :fname, presence: true
  validates :lname, presence: true
  validates :utype, presence: true,
                    numericality: { only_integer: true,
                                    less_than: 3,
                                    greater_than_or_equal_to: 0 }
  validates :mail, presence: true, uniqueness: true

  VALID_PASSWORD_REGEX = /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/

  validates :password, presence: { on: :create }

  before_validation :normalize_attributes

  def clear_password
    self.password = nil
  end

  def admin?
    utype == ADMIN
  end

  def professor?
    utype == PROFESSOR || admin?
  end

  def student?
    utype == STUDENT || professor?
  end

  private

  def normalize_attributes
    self.username = username.downcase
    self.mail = mail.downcase
    self.fname = fname.titleize.strip
    self.lname = lname.titleize.strip
  end
end
