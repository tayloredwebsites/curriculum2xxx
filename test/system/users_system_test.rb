require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'
require 'helpers/user_test_helper'
# require 'helpers/upload_data_test_helper'
# require 'test_helper_debugging'

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
    page.find("ul#locale-select a[href='/users/lang/en']").click
    page.find("#topNav a[href='/en/users/sign_in']").click
    within('#main-container h2') do
        assert page.has_content?('Sign in')
    end
    page.find("#main-container a[href='/en/users/sign_up']").click
    within('#main-container h2') do
      assert page.has_content?('Sign up')
    end
    fill_in "user_email", with: 'me@example.com'
    fill_in "user_password", with: 'password'
    fill_in "user_password_confirmation", with: 'password'

    # confirm no email sent without extra fields and confirmation checked
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      click_button "Sign up"
    end
    within 'form #error_explanation' do
      assert page.has_content?("First (Given) Name can't be blank")
      assert page.has_content?("Last (Family) Name can't be blank")
      assert page.has_content?("Government Level can't be blank")
      assert page.has_content?("Government Level Name can't be blank")
      assert page.has_content?("Municipality Name can't be blank")
      assert page.has_content?("Institution Type can't be blank")
      assert page.has_content?("Institution Name can't be blank")
      assert page.has_content?("Position Type can't be blank")
      assert page.has_content?("Subject Teaching can't be blank")
      # assert page.has_content?("Other Subject Teaching can't be blank")
      assert page.has_content?("Gender can't be blank")
      assert page.has_content?("Education Level Attained can't be blank")
      assert page.has_content?("Work Address can't be blank")
      assert page.has_content?("Terms and condition of use can't be blank")
    end

    fill_in "user_email", with: 'me@example.com'
    fill_in "user_password", with: 'password'
    fill_in "user_password_confirmation", with: 'password'
    fill_in "user_given_name", with: 'Help'
    fill_in "user_family_name", with: 'Me'
    select 'Entity', from: "user_govt_level"
    fill_in "user_govt_level_name", with: "user_govt_level_name"
    fill_in "user_municipality", with: "municipality"
    select 'Pedagogical Institute (PI)', from: "user_institute_type"
    fill_in "user_institute_name_loc", with: "institute_name_loc"
    select 'Educational professional', from: "user_position_type"
    fill_in "user_subject1", with: "subject1"
    fill_in "user_subject2", with: "subject2"
    select 'Female', from: "user_gender"
    select 'MA/MSc', from: "user_education_level"
    fill_in "user_work_phone", with: "work_phone"
    fill_in "user_work_address", with: "work_address"
    check 'user_terms_accepted'

    # confirm email sent with click of sign up button
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      click_button "Sign up"
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal "Confirmation instructions", email.subject
    assert_equal 'me@example.com', email.to[0]
    assert_match(/Welcome me@example.com!/, email.body.to_s)

    assert_equal(root_path('en'), current_path)
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

    page.find("#topNav a[href='/en/users/index']").click

    within("#main-container table#usersTable tr#id_#{new_user.id}") do
      page.find("a[href='/en/users/#{new_user.id}/edit']").click
    end

    # make newly registered user a teacher and web admin (note teacher has subtle differences from public)
    within("form[action='/en/users/#{new_user.id}']") do
      page.find("input[name='user[role_teacher]']").set(true)
      page.find("input[name='user[role_admin]']").set(true)
      page.find("button[name='submit']").click
    end

    # sign out and sign in as newly registered user
    # confirm
    page.find("#topNav a[href='/en/sign_out']").click
    system_sign_in(new_user, 'password')
    can_see_admin_pages
  end


  ##############################################
  # support methods
  ##############################################


  def can_see_public_pages(public=false)

    # nav to trees index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    page.find("#topNav a[href='/en/trees']").click
    sleep 1
    assert_equal(trees_path('en'), current_path)
    # at trees index page
    assert_equal 'Operational Teaching Curriculum (OTC) Listing', page.title
    within('#pageHeader h1') do
      assert page.has_content?('Operational Teaching Curriculum (OTC) Listing')
    end
    page.find("#topNav a[href='/en/users/home']").click
    assert_equal(home_users_path('en'), current_path)

    page.find("#topNav a[href='/en/trees']").click
    sleep 1
    assert_equal(trees_path('en'), current_path)
    # at trees index page
    if public
      page.find("#topNav a[href='/en/users/sign_in']").click
      sleep 1
      assert_equal(new_user_session_path('en'), current_path)
      within('#main-container h2') do
        assert page.has_content?('Sign in')
      end
    else
      within('#topNav') do
        assert page.has_content?('Sign Out')
      end
    end

  end

  def cannot_see_admin_pages(public=false)
    visit root_path
    assert_equal 0, page.find_all("#topNav a[href='/bs/users']").count
    assert_equal 0, page.find_all("#topNav a[href='/bs/user/#{@admin.id}/edit']").count
    assert_equal 0, page.find_all("#topNav a[href='/bs/uploads']").count
  end

  def can_see_admin_pages
    # nav to trees index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    page.find("#topNav a[href='/en/uploads']").click
    sleep 1
    assert_equal(uploads_path('en'), current_path)
    assert_equal I18n.translate('uploads.index.name'), page.title
    visit users_path
    assert_equal(users_path(), current_path)
    assert_equal I18n.translate('users.index.name'), page.title
    visit edit_user_path('bs', @admin.id)
    assert_equal(edit_user_path('bs', @admin.id), current_path)
    assert_equal I18n.translate('users.my_account.name'), page.title

    # via navbar
    assert_equal 1, page.find_all("#topNav a[href='/bs/uploads']").count
    assert_equal 1, page.find_all("#topNav a[href='/bs/users/index']").count
  end

  def can_see_self(user)
    # nav to trees index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    page.find("#topNav a[href='/en/users/#{user.id}/edit']").click
    sleep 1
    assert_equal(edit_user_path('en', user.id), current_path)
    assert_equal I18n.translate('users.my_account.name', locale: 'en'), page.title
  end

  def cannot_see_teacher_pages(public=false)
  end

  def can_see_teacher_pages
  end

end
