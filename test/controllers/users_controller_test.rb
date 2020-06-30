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

  test "Admin should be able to deactivate and restore users" do
    sign_in @admin
    # get 'Active Users' listing
    get users_path
    assert_response :success
    assert_select "#deactivate-#{@teacher.id}", text: "Deactivate"
    assert_select "#restore-#{@teacher.id}", false, "Active user should have no restore option"
    put "/users/#{@teacher.id}", params: { user: { active: false } }
    assert_redirected_to users_path
    get users_path
    @teacher.reload
    assert_equal false, @teacher.active
    assert_select "#deactivate-#{@teacher.id}", false, "Deactivated user should not appear on the 'Active Users' list"
    assert_select "#restore-#{@teacher.id}", false, "Deactivated user should not appear on the 'Active Users' list"
    # get 'All Users' listing
    get users_path(showDeactivated: true)
    assert_response :success
    assert_select "#restore-#{@teacher.id}", text: "Restore"
    assert_select "#deactivate-#{@teacher.id}", false, "Deactivated user should have no 'Deactivate' option"
    put "/users/#{@teacher.id}", params: { user: { active: true } }
    assert_redirected_to users_path
    get users_path
    @teacher.reload
    assert_equal true, @teacher.active
    assert_select "#deactivate-#{@teacher.id}", text: "Deactivate"
  end

  test "deactivated teacher should be unable to log in." do
    @teacher.update(active: false)
    sign_in @teacher
    get root_path
    assert_redirected_to new_user_session_path
    follow_redirect!
    @teacher.update(active: true)
    @teacher.reload
    sign_in @teacher
    get trees_path
    assert_response :success
  end

end
