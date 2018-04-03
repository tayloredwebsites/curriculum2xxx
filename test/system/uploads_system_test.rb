require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'

class UploadsSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper


  setup do
    @one = create(:user, roles: 'admin')
    @one.confirm
    sign_in @one
    testing_db_seeds
  end


  test "good upload" do
    visit uploads_path

    # uploads index page
    assert_equal(uploads_path(), current_path)
    # choose the chemistry grade band 9 english upload
    # to do - use translation when title is translated
    assert_equal 'Uploads Listing', page.title
    assert_equal 62, page.all('#uploadsTable tbody tr').count
    page.find("#uploadsTable tbody tr#id_#{@hem_09.id} a").click

    # chemistry grade band 9 english upload page, with status not uploaded
    assert_equal(start_upload_upload_path('bs', @hem_09.id), current_path)
    # do upload
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_09.status)
    assert_equal(0, Tree.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_9_en.csv'))
    find('button').click

    # at upload reporting page
    assert_equal(do_upload_upload_path('bs', @hem_09.id), current_path)
    refute_equal(0, Tree.count)

    # confirm
    # 4 area records were added
    # 16 components (4 per area +(4*4 = 16)
    # 48 outcomes (avg. 3 per component)
    assert_equal("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_SECTOR_RELATED]}", page.find('h4').text)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_SECTOR_RELATED, @hem_09.status)
    # confirm number of records returned is 4 (4 area records)
    rpt_rows = page.find_all('#uploadReport tbody tr .colStatusMsg')
    assert_equal 390, rpt_rows.count # 186 tree items + 119 KBE report records + 85 sector explanations
    assert_equal 0, page.find_all('div.error').count


    # run it again, and should have the same report
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_9_en.csv'))
    find('button').click
    assert_equal(do_upload_upload_path('bs', @hem_09.id), current_path)
    assert_equal("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_SECTOR_RELATED]}", page.find('h4').text)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_SECTOR_RELATED, @hem_09.status)
    assert_equal 390, page.find_all('#uploadReport tbody tr').count
    assert_equal 0, page.find_all('div.error').count
  end


  test "errors upload" do
    # uploads index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    # assert_equal "/users/lang/en", current_path
    # assert_equal home_users_path("en"), current_path
    page.find("#topNav a[href='/en/uploads']").click
    sleep 1
    assert_equal(uploads_path('en'), current_path)

    # to do - use translation when title is translated
    assert_equal 'Uploads Listing', page.title
    assert_equal 62, page.all('#uploadsTable tbody tr').count
    page.find("#uploadsTable tbody tr#id_#{@hem_13.id} a").click

    # uploads page, with status not uploaded
    assert_equal(start_upload_upload_path('en', @hem_13.id), current_path)
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end

    # do upload invalid filename
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_13.status)
    assert_equal(0, Tree.count)
    assert_equal(40, Translation.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_9_en.csv'))
    find('button').click
    assert_equal(do_upload_upload_path('en', @hem_13.id), current_path)
    assert page.has_content?(I18n.translate('uploads.errors.incorrect_filename', filename: @hem_13.filename))
    assert_equal 'Uploads Listing', page.title
    assert_equal(0, Tree.count)

    # do upload invalid file
    page.find("#uploadsTable tbody tr#id_#{@hem_13.id} a").click
    assert_equal(start_upload_upload_path('en', @hem_13.id), current_path)
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_13.status)
    assert_equal(0, Tree.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_13_en.csv'))
    find('button').click
    assert_equal(do_upload_upload_path('en', @hem_13.id), current_path)

    assert_equal(13, Tree.count)
    rows =  page.find_all('#uploadReport tbody tr')
    assert_equal 32, rows.count # 13 OTC + 10-1 sector explanations + 10-1 sectors added + 1 error
    assert_equal(61, Translation.count)  # nine items added to tree = 49 + 8 explanations ????
    assert_equal 2, page.find_all('div.error').count # 1crow for error row and 1 for count row

    # we got errors uploading tree.
    assert_equal("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_TREE_UPLOADING]}", page.find('h4').text)
    @hem_13.reload
    assert_equal(BaseRec::UPLOAD_TREE_UPLOADING, @hem_13.status)

  end


end
