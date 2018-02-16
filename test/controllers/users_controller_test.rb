require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'
require 'helpers/user_test_helper'


class UsersControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper
  include UserTestHelper

  setup do
    testing_db_seeds
    setup_all_users
  end

  test "public user should only see public pages" do
    get root_path
    assert_response :success
    get trees_path
    assert_response :success
    get uploads_path
    assert_response :redirect
    get users_path
    assert_response :redirect
    get edit_user_path(@admin.id)
    assert_response :redirect
    get edit_user_path(@req_teacher.id)
    assert_response :redirect
    get edit_user_path(@teacher.id)
    assert_response :redirect
    get new_user_session_path
    assert_response :success # ???
  end

  test "unauth user should only see public pages" do
    sign_in @unauth
    get root_path
    assert_response :success
    get trees_path
    assert_response :success
    get uploads_path
    assert_response :redirect
    get users_path
    assert_response :redirect
    get edit_user_path(@admin.id)
    assert_response :redirect
    get edit_user_path(@req_teacher.id)
    assert_response :redirect
    get edit_user_path(@teacher.id)
    assert_response :redirect
    get new_user_session_path
    assert_response :redirect # ???
  end

  test "teacher should only see appropriate pages" do
    sign_in @teacher
    get root_path
    assert_response :success
    get trees_path
    assert_response :success
    get uploads_path
    assert_response :redirect
    get users_path
    assert_response :redirect
    get edit_user_path(@admin.id)
    assert_response :redirect
    get edit_user_path(@req_teacher.id)
    assert_response :redirect
    get edit_user_path(@teacher.id)
    assert_response :success
    get new_user_session_path
    assert_response :redirect # ???
  end

  test "requesting teacher should only see appropriate pages" do
    sign_in @req_teacher
    get root_path
    assert_response :success
    get trees_path
    assert_response :success
    get uploads_path
    assert_response :redirect
    get users_path
    assert_response :redirect
    get edit_user_path(@admin.id)
    assert_response :redirect
    get edit_user_path(@teacher.id)
    assert_response :redirect
    get edit_user_path(@req_teacher.id)
    assert_response :success
    get new_user_session_path
    assert_response :redirect # ???
  end

  test "admin user should see all pages" do
    sign_in @admin
    get root_path
    assert_response :success
    get trees_path
    assert_response :success
    get uploads_path
    assert_response :success
    get users_path
    assert_response :success
    get edit_user_path(@admin.id)
    assert_response :success
    get edit_user_path(@req_teacher.id)
    assert_response :success
    get edit_user_path(@teacher.id)
    assert_response :success
    get new_user_session_path
    assert_response :redirect # ???
  end

  test "admin user should be able to create, edit and view all users" do
    sign_in @admin
    get users_path
    assert_response :success
    get edit_user_path(@unauth.id)
    assert_response :success
    assert_equal '', assigns(:user).roles
    patch "/users/#{@unauth.id}", params: { user: { role_admin: 'on', role_teacher: 'on', role_req_teacher: 'off' } }
    assert_response :success
    assert assigns(:user).roles.include?(User::TEACHER_ROLE)
    assert assigns(:user).roles.include?(User::ADMIN_ROLE)
    assert_not assigns(:user).roles.include?(User::REQ_TEACHER_ROLE)
  end

end
