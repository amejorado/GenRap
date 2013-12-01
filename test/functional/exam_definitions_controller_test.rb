require 'test_helper'

class ExamDefinitionsControllerTest < ActionController::TestCase
  setup do
    @exam_definition = exam_definitions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exam_definitions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exam_definition" do
    assert_difference('ExamDefinition.count') do
      post :create, exam_definition: {  }
    end

    assert_redirected_to exam_definition_path(assigns(:exam_definition))
  end

  test "should show exam_definition" do
    get :show, id: @exam_definition
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @exam_definition
    assert_response :success
  end

  test "should update exam_definition" do
    put :update, id: @exam_definition, exam_definition: {  }
    assert_redirected_to exam_definition_path(assigns(:exam_definition))
  end

  test "should destroy exam_definition" do
    assert_difference('ExamDefinition.count', -1) do
      delete :destroy, id: @exam_definition
    end

    assert_redirected_to exam_definitions_path
  end
end
