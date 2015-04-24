require 'test_helper'

class ProjectUsersControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project_user = project_users(:one)
  end

  test "should resend project invitation" do
    post :resend, id: @project_user, format: 'js'

    assert_not_nil assigns(:project_user)
    assert_not_nil assigns(:project)
    assert_template 'resend'
  end

  test "should not resend project invitation with invalid id" do
    post :resend, id: -1, format: 'js'

    assert_nil assigns(:project_user)
    assert_nil assigns(:project)
    assert_response :success
  end

  test "should create project user" do
    assert_difference('ProjectUser.count') do
      post :create, project_user: { project_id: projects(:one).id, editor: true }, editors_text: users(:two).name + " [#{users(:two).email}]", format: 'js'
    end

    assert_not_nil assigns(:project_user)
    assert_template 'index'
  end

  test "should create project user and automatically add associated user" do
    assert_difference('ProjectUser.count') do
      post :create, project_user: { project_id: projects(:four).id, editor: true }, editors_text: users(:associated).name + " [#{users(:associated).email}]", format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:user)

    assert_not_nil assigns(:project_user)
    assert_template 'index'
  end

  test "should create project user invitation" do
    assert_difference('ProjectUser.count') do
      post :create, project_user: { project_id: projects(:one).id, editor: true }, editors_text: "invite@example.com", format: 'js'
    end

    assert_not_nil assigns(:project_user)
    assert_not_nil assigns(:project_user).invite_token

    assert_template 'index'
  end

  test "should not create project user with invalid project id" do
    assert_difference('ProjectUser.count', 0) do
      post :create, project_user: { project_id: -1, editor: true }, editors_text: users(:two).name + " [#{users(:two).email}]", format: 'js'
    end

    assert_nil assigns(:project_user)
    assert_response :success
  end

  test "should accept project user" do
    login(users(:two))
    get :accept, invite_token: project_users(:invited).invite_token

    assert_not_nil assigns(:project_user)
    assert_equal users(:two), assigns(:project_user).user
    assert_equal "You have been successfully been added to the project.", flash[:notice]
    assert_redirected_to assigns(:project_user).project
  end

  test "should accept existing project user" do
    get :accept, invite_token: project_users(:two).invite_token

    assert_not_nil assigns(:project_user)
    assert_equal users(:valid), assigns(:project_user).user
    assert_equal "You have already been added to #{assigns(:project_user).project.name}.", flash[:notice]
    assert_redirected_to assigns(:project_user).project
  end

  test "should not accept invalid token for project user" do
    get :accept, invite_token: 'imaninvalidtoken'

    assert_nil assigns(:project_user)
    assert_equal 'Invalid invitation token.', flash[:alert]
    assert_redirected_to root_path
  end

  test "should not accept project user if invite token is already claimed" do
    login(users(:two))
    get :accept, invite_token: 'validintwo'

    assert_not_nil assigns(:project_user)
    assert_not_equal users(:two), assigns(:project_user).user
    assert_equal "This invite has already been claimed.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should destroy project user" do
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, id: @project_user, format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_template 'index'
  end

  test "should allow viewer to remove self from project" do
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, id: project_users(:five), format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_template 'index'
  end

  test "should not destroy project user with invalid id" do
    assert_difference('ProjectUser.count', 0) do
      delete :destroy, id: -1, format: 'js'
    end

    assert_nil assigns(:project)
    assert_response :success
  end
end
