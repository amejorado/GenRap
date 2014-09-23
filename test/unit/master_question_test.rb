require 'test_helper'

class MasterQuestionTest < ActiveSupport::TestCase
  test 'returns all languages' do
    languages = MasterQuestion.all_languages
    languages_strings = languages.map(&:language)
    assert_equal(languages_strings, %w(Python MyString))
  end
end
