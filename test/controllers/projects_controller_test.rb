require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should get randomizations for viewer" do
    login(users(:viewer))
    get :randomizations, id: @project
    assert_response :success
  end

  test "should get randomize subject for viewer" do
    login(users(:viewer))
    get :randomize_subject, id: @project
    assert_response :success
  end

  test "should create randomization for viewer" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S0123', stratum_1: 'BOS', stratum_2: 'Male'
    assert_not_nil assigns(:assignment)
    assert_equal 'S0123', assigns(:assignment).subject_code
    assert_equal users(:viewer), assigns(:assignment).user
    assert_not_nil assigns(:assignment).randomized_at
    assert_equal 'BOS, Male', assigns(:assignment).list_name
    assert_equal 1, assigns(:assignment).position
    assert_equal "Arm B", assigns(:assignment).treatment_arm
    assert_redirected_to project_assignment_path(assigns(:project), assigns(:assignment))
  end

  test "should not create randomization for blank subject" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: '', stratum_1: 'BOS', stratum_2: 'Male'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:subject_code]
    assert_template 'randomize_subject'
  end

  test "should not create randomization for existing subject" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S1234', stratum_1: 'BOS', stratum_2: 'Male'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["has already been randomized"], assigns(:project).errors[:subject_code]
    assert_template 'randomize_subject'
  end

  test "should not create randomization for list that is full" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S4567', stratum_1: 'BOS', stratum_2: 'Female'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["BOS, Female is already full"], assigns(:project).errors[:list]
    assert_template 'randomize_subject'
  end

  test "should not create randomization for list that does not exist" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S5566', stratum_1: 'SPR', stratum_2: 'Female'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["SPR, Female does not exist"], assigns(:project).errors[:list]
    assert_template 'randomize_subject'
  end

  test "should not create randomization without selected stratum" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S1112'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["must be selected"], assigns(:project).errors[:stratification_factors]
    assert_template 'randomize_subject'
  end

  test "should generate lists" do
    post :generate_lists, id: @project, format: 'js'
    assert_response :success
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
      post :create, project: { description: @project.description, name: @project.name, treatment_arms: [ { name: 'Arm One', allocation: 1 }, { name: 'Arm Two', allocation: 1 } ], block_size_multipliers: [ { value: '1', allocation: '1' }, { value: '2', allocation: '1' } ], stratification_factors: [ { name: 'Gender', options: [ 'Male', 'Female' ]}] }
    end

    assert_equal 2, assigns(:project).treatment_arms.size
    assert_redirected_to project_path(assigns(:project))
  end

  test "should not create project with blank name" do
    assert_difference('Project.count', 0) do
      post :create, project: { description: @project.description, name: '' }
    end

    assert_not_nil assigns(:project)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template 'new'
  end

  test "should show project" do
    get :show, id: @project
    assert_response :success
  end

  test "should show project with one stratification factor" do
    get :show, id: projects(:four)
    assert_response :success
  end

  test "should show project with no stratification factors" do
    get :show, id: projects(:empty)
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

  test "should not update project with blank name" do
    put :update, id: @project, project: { description: @project.description, name: '' }

    assert_not_nil assigns(:project)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template 'edit'
  end

  test "should destroy project" do
    assert_difference('Project.current.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end
end
