require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'

class SectorsSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user)
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "Sectors index page" do
    visit sectors_url
    assert_equal("/sectors/index", current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    # assert the report header does not show if report has not been generated yet
    assert_equal(0, page.find_all('table.tree-listing thead tr.rpt-header').count)
    # asset no report records yet
    assert_equal 0, page.all('table.tree-listing tbody tr.rpt').count
    # page.find("form.new_sector input[type='submit']").click
    page.find("form#new_sector input[name='commit']").click
    assert_equal("/sectors/index", current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    assert_equal 10, page.all('table.tree-listing tr.rpt').count # Only sectors listed, no curriculum loaded yet
  end

  test "Test curriculum from chemistry 09 english upload file" do
    visit uploads_url
    assert_equal("/uploads", current_path)
    page.find("#uploadsTable tbody tr#id_#{@hem_09.id} a").click
    assert_equal("/uploads/#{@hem_09.id}/start_upload", current_path)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    assert_equal("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_SECTOR_RELATED]}", page.find('h4').text)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_SECTOR_RELATED, @hem_09.status)
    assert_equal 305, page.find_all('#uploadReport tbody tr').count
    assert_equal 0, page.find_all('div.error').count

    visit sectors_url
    assert_equal("/sectors/index", current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    page.find("form#new_sector input[name='commit']").click
    assert_equal("/sectors/index", current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    assert_equal '1 - Information Communication Technology (ICT)', page.find("tr[data-row='0'] td.sector-row").text
    assert_equal '1.1.1.b', page.find("tr[data-row='1'] td.code-col").text
    assert_equal 367, page.all('table.tree-listing tr.rpt').count

    assert_equal("/sectors/index", current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    select('Information Communication Technology (ICT)', from: "tree_sector_id")
    page.find("form#new_sector input[name='commit']").click
    assert_equal("/sectors/index", current_path)
    assert_equal I18n.translate('sectors.index.title'), page.title
    assert_equal '1 - Information Communication Technology (ICT)', page.find("tr[data-row='0'] td.sector-row").text
    assert_equal '1.1.1.b', page.find("tr[data-row='1'] td.code-col").text
    assert_equal 27, page.all('table.tree-listing tr.rpt').count

  end


end
