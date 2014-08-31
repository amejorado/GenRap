require 'test_helper'

class SubConceptsControllerTest < ActionController::TestCase
  setup do
    @sub_concept = sub_concepts(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:sub_concepts)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create sub_concept' do
    assert_difference('SubConcept.count') do
      post :create, sub_concept: { concept_id: @sub_concept.concept_id, name: @sub_concept.name }
    end

    assert_redirected_to sub_concept_path(assigns(:sub_concept))
  end

  test 'should show sub_concept' do
    get :show, id: @sub_concept
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @sub_concept
    assert_response :success
  end

  test 'should update sub_concept' do
    put :update, id: @sub_concept, sub_concept: { concept_id: @sub_concept.concept_id, name: @sub_concept.name }
    assert_redirected_to sub_concept_path(assigns(:sub_concept))
  end

  test 'should destroy sub_concept' do
    assert_difference('SubConcept.count', -1) do
      delete :destroy, id: @sub_concept
    end

    assert_redirected_to sub_concepts_path
  end
end
