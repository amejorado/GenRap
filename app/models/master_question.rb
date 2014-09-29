# encoding: utf-8
class MasterQuestion < ActiveRecord::Base
  has_many :master_exams, through: :exam_definition
  has_many :questions, dependent: :destroy
  has_many :exam_definition, dependent: :destroy

  belongs_to :language
  belongs_to :concept
  belongs_to :sub_concept, foreign_key: 'subconcept_id'

  validates :concept, presence: true
  validates :inquiry, presence: true
  validates :language, presence: true
  validates :randomizer, presence: true
  validates :solver, presence: true
  validates :sub_concept, presence: true
  validates :borrado, presence: true

  validate :randomizer_code_is_correct
  validate :solver_code_is_correct

  attr_accessible :concept, :inquiry, :language, :randomizer, :solver,
                  :subconcept, :borrado, :questionDateDeleted, :concept_id,
                  :language_id, :subconcept_id

  def self.all_languages
    select('DISTINCT language')
  end

  def load_randomizer_and_solver!
    eval randomizer, binding
    eval solver, binding
  end

  private

  def randomizer_code_is_correct
    begin
      eval randomizer, binding
      begin
        randomize(inquiry)
      rescue Exception => e
        errors.add :randomizer, "tiene errores de ejecución</br>#{e.message}"
      end
    rescue Exception => e
      errors.add :randomizer, "tiene errores de compilación</br>#{e.message}"
    end
  end

  def solver_code_is_correct
    begin
      eval solver, binding
      return if errors.messages[:randomizer]
      begin
        solve(inquiry, randomize(inquiry))
      rescue Exception => e
        errors.add :solver, "tiene errores de ejecución</br>#{e.message}"
      end
    rescue Exception => e
      errors.add :solver, "tiene errores de compilación</br>#{e.message}"
    end
  end
end
