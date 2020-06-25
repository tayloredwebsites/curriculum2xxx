require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'
require 'helpers/user_test_helper'
# require 'test_helper_debugging'


class UsersControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper
  include UserTestHelper

  setup do
    testing_db_tfv_seed
    setup_all_users
  end

  test "public user should only see sign_in page" do
    get root_path
    assert_redirected_to new_user_session_path
    get trees_path
    assert_redirected_to new_user_session_path
    get uploads_path
    assert_redirected_to new_user_session_path
    get users_path
    assert_redirected_to new_user_session_path
    get edit_user_path('en', @admin.id)
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_user_session_path
    get edit_user_path('en', @teacher.id)
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_user_session_path
    get new_user_session_path
    assert_response :success
  end

  test "unauth user should only see public pages" do
    sign_in @unauth
    get root_path
    assert_redirected_to new_user_session_path
    get trees_path
    assert_redirected_to new_user_session_path
    get uploads_path
    assert_redirected_to new_user_session_path
    get users_path
    assert_redirected_to new_user_session_path
    get edit_user_path('en', @admin.id)
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_user_session_path
    get edit_user_path('en', @teacher.id)
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_user_session_path
    get new_user_session_path
    assert_response :success
  end

  test "teacher should only see appropriate pages" do
    sign_in @teacher
    get root_path
    assert_redirected_to root_path('en')
    get trees_path
    assert_response :success
    get uploads_path
    assert_redirected_to root_path('en')
    get users_path
    assert_redirected_to root_path('en')
    get edit_user_path('en', @admin.id)
    assert_redirected_to root_path('en')
    get edit_user_path('en', @unauth.id)
    assert_redirected_to root_path('en')
    get edit_user_path('en', @teacher.id)
    assert_response :success
    get new_user_session_path
    assert_redirected_to root_path('en')
  end

  test "admin user should see all pages" do
    sign_in @admin
    get root_path
    assert_redirected_to root_path('en')
    get trees_path
    assert_response :success
    get uploads_path
    assert_response :success
    get users_path
    assert_response :success
    get edit_user_path('en', @admin.id)
    assert_response :success
    get edit_user_path('en', @unauth.id)
    assert_response :success
    get edit_user_path('en', @teacher.id)
    assert_response :success
    get new_user_session_path
    assert_redirected_to root_path('en')
  end

  test "admin user should be able to create, edit and view all users" do
    sign_in @admin
    get users_path
    assert_response :success
    get edit_user_path('en', @unauth.id)
    assert_response :success
    assert_equal '', assigns(:user).roles
    patch "/users/#{@unauth.id}", params: { user: { role_admin: 'on', role_teacher: 'on' } }
    assert_response :success
    assert assigns(:user).roles.include?(User::TEACHER_ROLE)
    assert assigns(:user).roles.include?(User::ADMIN_ROLE)
  end

end
