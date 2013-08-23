require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @assignment = assignments(:one)
  end

  test "should get index" do
    get :index, project_id: @project.id
    assert_response :success
    assert_not_nil assigns(:assignments)
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create assignment" do
  #   assert_difference('Assignment.count') do
  #     post :create, assignment: { block_group: @assignment.block_group, list_name: @assignment.list_name, multiplier: @assignment.multiplier, position: @assignment.position, project_id: @assignment.project_id, randomized_at: @assignment.randomized_at, subject_code: @assignment.subject_code, treatment_arm: @assignment.treatment_arm }
  #   end

  #   assert_redirected_to assignment_path(assigns(:assignment))
  # end

  test "should show assignment" do
    get :show, id: @assignment, project_id: @project.id
    assert_response :success
  end

  # test "should get edit" do
  #   get :edit, id: @assignment
  #   assert_response :success
  # end

  # test "should update assignment" do
  #   patch :update, id: @assignment, assignment: { block_group: @assignment.block_group, list_name: @assignment.list_name, multiplier: @assignment.multiplier, position: @assignment.position, project_id: @assignment.project_id, randomized_at: @assignment.randomized_at, subject_code: @assignment.subject_code, treatment_arm: @assignment.treatment_arm }
  #   assert_redirected_to assignment_path(assigns(:assignment))
  # end

  test "should remove assignment randomization" do
    delete :destroy, id: @assignment, project_id: @project.id

    assert_nil assigns(:assignment).subject_code
    assert_nil assigns(:assignment).randomized_at

    assert_redirected_to project_assignment_path(assigns(:project), assigns(:assignment))
  end
end
