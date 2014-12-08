require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should get csv" do
    get :randomizations, id: @project, format: 'csv'
    assert_not_nil assigns(:csv_string)
    assert_response :success
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
    post :create_randomization, id: @project, subject_code: 'S0123', stratum_1: 'BOS', stratum_2: 'Male', attested: '1'
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
    post :create_randomization, id: @project, subject_code: '', stratum_1: 'BOS', stratum_2: 'Male', attested: '1'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:subject_code]
    assert_template 'randomize_subject'
  end

  test "should not create randomization for existing subject" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S1234', stratum_1: 'BOS', stratum_2: 'Male', attested: '1'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["has already been randomized"], assigns(:project).errors[:subject_code]
    assert_template 'randomize_subject'
  end

  test "should not create randomization for list that is full" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S4567', stratum_1: 'BOS', stratum_2: 'Female', attested: '1'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["BOS, Female is already full"], assigns(:project).errors[:list]
    assert_template 'randomize_subject'
  end

  test "should not create randomization for list that does not exist" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S5566', stratum_1: 'SPR', stratum_2: 'Female', attested: '1'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["SPR, Female does not exist"], assigns(:project).errors[:list]
    assert_template 'randomize_subject'
  end

  test "should not create randomization without selected stratum" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S1112', attested: '1'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["must be selected"], assigns(:project).errors[:stratification_factors]
    assert_template 'randomize_subject'
  end

  test "should not create randomization without attesting" do
    login(users(:viewer))
    post :create_randomization, id: @project, subject_code: 'S0123', stratum_1: 'BOS', stratum_2: 'Male', attested: '0'
    assert_nil assigns(:assignment)
    assert assigns(:project).errors.size > 0
    assert_equal ["must be checked"], assigns(:project).errors[:attested]
    assert_template 'randomize_subject'
  end

  # 7 Minimum Block Group Size = ( 1x Block Size 3 + 1x Block Size 2 + 2x Block Size 1 )
  # 35 Minimum Block Size = 5 Treatment Options ( 1 of A + 2 of B + 2 of C ) * 7 Minimum Block Group Size
  # 105 Blocks Per List = 3 (# of Block Groups of size 35 required to cover Randomization Goal of 80) * 35 Minimum Block Size
  # 210 Assignments = 2 Lists (Gender Male, Gender Female) * ( 105 Blocks Per List )
  test "should generate lists" do
    assert_difference('Assignment.count', 210) do
      post :generate_lists, id: projects(:four), format: 'js'
    end
    assert_response :success
  end

  test "should not generate lists if randomization has started" do
    assert_difference('Assignment.count', 0) do
      post :generate_lists, id: @project, format: 'js'
    end
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
      post :create, project: { description: @project.description, name: @project.name, randomization_requirements: 'Requirements', treatment_arms: [ { name: 'Arm One', allocation: 1 }, { name: 'Arm Two', allocation: 1 } ], block_size_multipliers: [ { value: '1', allocation: '1' }, { value: '2', allocation: '1' } ], stratification_factors: [ { name: 'Gender', options: [ 'Male', 'Female' ]}] }
    end

    assert_equal 2, assigns(:project).treatment_arms.size
    assert_equal 'Requirements', assigns(:project).randomization_requirements
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
    patch :update, id: @project, project: { description: @project.description, name: @project.name, randomization_requirements: 'Requirements Updated', treatment_arms: [ { name: 'Arm One', allocation: 1 }, { name: 'Arm Two', allocation: 1 }, { name: 'Arm Three', allocation: 1 } ] }

    assert_equal 3, assigns(:project).treatment_arms.size
    assert_equal 'Requirements Updated', assigns(:project).randomization_requirements
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
