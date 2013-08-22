require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: { description: @project.description, name: @project.name, treatment_arms: [ { name: 'Arm One', allocation: 1 }, { name: 'Arm Two', allocation: 1 } ] }
    end

    assert_equal 2, assigns(:project).treatment_arms.size
    assert_redirected_to project_path(assigns(:project))
  end

  test "should show project" do
    get :show, id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project
    assert_response :success
  end

  test "should update project" do
    patch :update, id: @project, project: { description: @project.description, name: @project.name, treatment_arms: [ { name: 'Arm One', allocation: 1 }, { name: 'Arm Two', allocation: 1 }, { name: 'Arm Three', allocation: 1 } ] }

    assert_equal 3, assigns(:project).treatment_arms.size
    assert_redirected_to project_path(assigns(:project))
  end

  test "should destroy project" do
    assert_difference('Project.current.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end
end
