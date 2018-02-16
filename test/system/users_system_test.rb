require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'
require 'helpers/user_test_helper'
# require 'helpers/upload_data_test_helper'

class UsersSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper
  include UserTestHelper
  include UserSystemHelper
  # include UploadDataTestHelper

  setup do
    testing_db_seeds
    setup_all_users
  end


  ##############################################
  # tests
  ##############################################


  test "each user type should only see appropriate pages" do

    # visits to pages
    # not logged in - public user
    can_see_public_pages(true)
    cannot_see_teacher_pages
    cannot_see_admin_pages(true)
    sign_in @unauth
    can_see_public_pages(false)
    can_see_self(@unauth)
    cannot_see_teacher_pages
    cannot_see_admin_pages(false)
    sign_in @teacher
    can_see_public_pages(false)
    can_see_self(@teacher)
    can_see_teacher_pages
    cannot_see_admin_pages(false)
    sign_in @admin
    can_see_public_pages(false)
    can_see_self(@admin)
    can_see_teacher_pages
    can_see_admin_pages
  end

  # test "Test curriculum from uploaded file" do
  #   load_curriculum_file_hem09
  #   # good_upload_check_curriculum
  #   good_detail_page
  # end

  test "Registration Process" do
    visit root_path
    page.find("#topNav a[href='/users/sign_in']").click
    within('#main-container h2') do
      assert page.has_content?('Log in')
    end
    page.find("#main-container a[href='/users/sign_up']").click
    within('#main-container h2') do
      assert page.has_content?('Sign up')
    end
    fill_in "user_email", with: 'me@example.com'
    fill_in "user_password", with: 'password'
    fill_in "user_password_confirmation", with: 'password'

    # confirm email sent with click of sign up button
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      click_button "Sign up"
    end

    fill_in "user_email", with: 'me@example.com'
    fill_in "user_password", with: 'password'
    fill_in "user_password_confirmation", with: 'password'
    fill_in "user_given_name", with: 'Help'
    fill_in "user_family_name", with: 'Me'

    # confirm email sent with click of sign up button
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      click_button "Sign up"
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal "Confirmation instructions", email.subject
    assert_equal 'me@example.com', email.to[0]
    assert_match(/Welcome me@example.com!/, email.body.to_s)

    assert_equal("/", current_path)
    assert_equal I18n.translate('home.title'), page.title
    assert page.has_content?(
      'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    )

    # activate the new user
    new_user = User.where(email: 'me@example.com').first
    assert true, new_user.present?
    new_user.confirm
    new_user.save

    # sign out and sign in as web admin
    system_sign_in(@admin)

    page.find("#topNav a[href='/users']").click

    within("#main-container table#usersTable tr#id_#{new_user.id}") do
      page.find("a[href='/users/#{new_user.id}/edit']").click
    end

    # make newly registered user a teacher and web admin (note teacher has subtle differences from public)
    within("form[action='/users/#{new_user.id}']") do
      page.find("input[name='user[role_teacher]']").set(true)
      page.find("input[name='user[role_admin]']").set(true)
      page.find("button[name='submit']").click
    end

    # sign out and sign in as newly registered user
    # confirm
    page.find("#topNav a[href='/users/sign_out']").click
    system_sign_in(new_user, 'password')
    can_see_admin_pages
  end


  ##############################################
  # support methods
  ##############################################


  def can_see_public_pages(public=false)

    # via url
    visit root_path
    assert_equal("/", current_path)
    assert_equal 'Home Page', page.title
    within('#pageHeader h1') do
      assert page.has_content?('Home Page')
    end
    visit trees_path
    assert_equal("/trees", current_path)
    assert_equal 'Operational Teaching Curriculum (OTC) Listing', page.title
    within('#pageHeader h1') do
      assert page.has_content?('Operational Teaching Curriculum (OTC) Listing')
    end
    page.find("#topNav a[href='/']").click
    assert_equal("/", current_path)

    # via navbar
    page.find("#topNav a[href='/trees']").click
    assert_equal("/trees", current_path)
    if public
      page.find("#topNav a[href='/users/sign_in']").click
      assert_equal("/users/sign_in", current_path)
      within('#main-container h2') do
        assert page.has_content?('Log in')
      end
    else
      within('#topNav') do
        assert page.has_content?('Sign Out')
      end
    end

  end

  def cannot_see_admin_pages(public=false)
    visit uploads_path
    assert_equal((public ? "/users/sign_in" : "/"), current_path)
    assert_equal I18n.translate((public ? "app.title" : 'home.title')), page.title
    visit users_path
    assert_equal("/", current_path)
    assert_equal I18n.translate('home.title'), page.title
    visit edit_user_path(@admin.id)
    assert_equal("/", current_path)
    assert_equal I18n.translate('home.title'), page.title

    # via navbar
    assert_equal 0, page.find_all("#topNav a[href='/uploads']").count
    assert_equal 0, page.find_all("#topNav a[href='/users']").count
  end

  def can_see_admin_pages
    visit uploads_path
    assert_equal("/uploads", current_path)
    assert_equal I18n.translate('uploads.index.name'), page.title
    visit users_path
    assert_equal("/users/index", current_path)
    assert_equal I18n.translate('users.index.name'), page.title
    visit edit_user_path(@admin.id)
    assert_equal("/users/#{@admin.id}/edit", current_path)
    assert_equal I18n.translate('users.my_account.name'), page.title

    # via navbar
    assert_equal 1, page.find_all("#topNav a[href='/uploads']").count
    assert_equal 1, page.find_all("#topNav a[href='/users']").count
  end

  def can_see_self(user)
    visit edit_user_path(user.id)
    assert_equal("/users/#{user.id}/edit", current_path)
    assert_equal I18n.translate('users.my_account.name'), page.title
    # visit new_user_session_path
    # assert_equal("/", current_path)
    # assert_equal I18n.translate('home.title'), page.title

    # via navbar
    assert_equal 1, page.find_all("#topNav a[href='/users/#{user.id}/edit']").count
  end

  def cannot_see_teacher_pages(public=false)
  end

  def can_see_teacher_pages
  end

end
