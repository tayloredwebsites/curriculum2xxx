require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'
# require 'test_helper_debugging'

class SectorsSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user, roles: 'admin')
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "Sectors index page" do
    visit sectors_path
    # assert_equal(sectors_path('bs'), current_path)
    assert_equal(sectors_path(), current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    # assert the report header does not show if report has not been generated yet
    assert_equal(0, page.find_all('table.tree-listing thead tr.rpt-header').count)
    # asset no report records yet
    assert_equal 0, page.all('table.tree-listing tbody tr.rpt').count
    # page.find("form.new_sector input[type='submit']").click
    page.find("form#new_sector input[name='commit']").click
    assert_equal(sectors_path('bs'), current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    assert_equal 10, page.all('table.tree-listing tr.rpt').count # Only sectors listed, no curriculum loaded yet
  end

  test "Test curriculum from chemistry 09 english upload file" do
    visit uploads_path
    # assert_equal(uploads_path('bs'), current_path)
    assert_equal(uploads_path(), current_path)
    page.find("#uploadsTable tbody tr#id_#{@hem_09.id} a").click
    assert_equal(start_upload_upload_path('bs', @hem_09.id), current_path)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_9_en.csv'))
    find('button').click
    assert_equal(do_upload_upload_path('bs', @hem_09.id), current_path)
    assert_equal("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_SECTOR_RELATED]}", page.find('h4').text)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_SECTOR_RELATED, @hem_09.status)
    assert_equal 390, page.find_all('#uploadReport tbody tr').count
    assert_equal 0, page.find_all('div.error').count

    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    assert_equal "/users/lang/en", current_path
    # assert_equal lang_user_path('en'), current_path
    # assert_equal 0, page.find_all("#topNav a[href='/bs/trees']").count
    # assert_equal 1, page.find_all("#topNav a[href='/en/trees']").count
    page.find("#topNav a[href='/en/trees']").click
    assert_equal(trees_path('en'), current_path)
    page.find(".filter-sectors a[href='#{sectors_path('en')}']").click
    assert_equal(sectors_path('en'), current_path)
    # assert_equal I18n.translate('sectors.index.title', locale: :en), page.title
    select('Hem', from: "tree_subject_id")
    select('9', from: "tree_grade_band_id")

    page.find("form[action='/en/sectors/index'] input[name='commit']").click
    assert_equal(sectors_path('en'), current_path)
    assert_equal I18n.translate('sectors.index.title', locale: :en), page.title
    assert_equal '1 - IT', page.find("tr[data-row='0'] td.sector-row").text
    assert_equal '1.1.1.b', page.find("tr[data-row='1'] td.code-col").text
    assert_equal 130, page.all('table.tree-listing tr.rpt').count

    assert_equal(sectors_path('en'), current_path)
    assert_equal I18n.translate('sectors.index.title', locale: :en), page.title
    select('IT', from: "tree_sector_id")
    page.find("form#new_sector input[name='commit']").click
    assert_equal(sectors_path('en'), current_path)
    assert_equal I18n.translate('sectors.index.title', locale: :en), page.title
    assert_equal '1 - IT', page.find("tr[data-row='0'] td.sector-row").text
    assert_equal '1.1.1.b', page.find("tr[data-row='1'] td.code-col").text
    assert_equal 6, page.all('table.tree-listing tr.rpt').count

  end


end
