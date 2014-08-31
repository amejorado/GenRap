# encoding: utf-8

class User < ActiveRecord::Base
  has_secure_password
  attr_accessible :fname, :lname, :password, :username, :email, :password_confirmation, :group_ids, :mail, :utype

  has_and_belongs_to_many :groups # , :inverse_of => :users
  has_many :groups_owned, class_name: 'Group', inverse_of: :user,
                          dependent: :destroy
  has_many :cantakes, dependent: :destroy
  has_many :master_exams, through: :cantakes # , :inverse_of => :users
  has_many :exams, dependent: :destroy # , :inverse_of => :user

  validates :username,  presence: true,
                        uniqueness: true
  #:length => { :is => 9 }#
  validates_uniqueness_of :username, message: 'El usuario no es unico'

  validates :fname,  presence: true
  validates :lname,  presence: true
  validates :utype,  presence: true,
                     numericality: {   only_integer: true,
                                       less_than: 3,
                                       greater_than_or_equal_to: 0 }
  validates :mail,  presence: true,
                    uniqueness: true
  validates_uniqueness_of :mail, message: 'El correo no es unico'
  VALID_PASSWORD_REGEX = /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/
  validates_presence_of :password,  on: :create
  # validates_confirmation_of :password, message: "debería coincidir con el password", presence: true

  before_save :normalizeAttributes
  # after_save :clear_password

  def clear_password
    self.password = nil
  end

  def normalizeAttributes
    self.username = username.downcase
    self.mail = mail.downcase

    f = ''
    for t in fname.split(' ')
      f += t.capitalize + ' '
    end
    self.fname = f.lstrip

    l = ''
    for t in lname.split(' ')
      l += t.capitalize + ' '
    end

    self.lname = l.lstrip
  end
end
