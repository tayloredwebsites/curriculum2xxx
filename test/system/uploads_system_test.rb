require 'application_system_test_case'
require 'helpers/seeds_testing_helper'

class UploadsSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user)
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "upload from index page" do
    visit uploads_url

    # uploads index page
    assert_equal("/uploads", current_path)
    # to do - use translation when title is translated
    assert_equal 'Uploads Listing', page.title
    assert_equal 1, page.all('#uploadsTable tbody tr').count
    page.find("#uploadsTable tbody tr#id_#{@hem_09.id} a").click

    # uploads page, with status not uploaded
    assert_equal("/uploads/#{@hem_09.id}/start_upload", current_path)
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end

    # do upload
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_09.status)
    assert_equal(0, Tree.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    refute_equal(0, Tree.count)
    # confirm
    # 4 area records were added
    # 16 components (4 per area +(4*4 = 16)
    # 48 outcomes (avg. 3 per component)
    assert_equal(186, Tree.where(parent_id: nil).count)
    puts "@hem_09 status: #{@hem_09.status}"
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_TREE_UPLOADED, @hem_09.status)
    # confirm number of records returned is 4 (4 area records)
    rpt_rows = page.find_all('#uploadReport tbody tr .colStatusMsg')
    assert_equal rpt_rows.count, 186
    save_and_open_page
    rpt_rows.each do |r|
      assert_equal 'Code Added Text Added', r.text
    end


    # run it again, and should have the same report
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_TREE_UPLOADED, @hem_09.status)
    assert_equal 186, page.find_all('#uploadReport tbody tr').count

    check_curriculum_page_after_upload

  end

  def check_curriculum_page_after_upload
    visit trees_url
    # uploads index page
    assert_equal("/trees", current_path)
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal("/trees/index_listing", current_path)
    assert_equal 4, page.all('#tree .node-tree').count
    within("#tree li[data-nodeid='0']") do
      # ensure user can check and uncheck checkbox
      assert_equal 1, page.find_all("span.glyphicon-unchecked").count
      assert_equal 0, page.find_all("span.glyphicon-check").count
      page.find("span.glyphicon-unchecked").click
      assert_equal 0, page.find_all("span.glyphicon-unchecked").count
      assert_equal 1, page.find_all("span.glyphicon-check").count
      page.find("span.glyphicon-check").click
      assert_equal 1, page.find_all("span.glyphicon-unchecked").count
      assert_equal 0, page.find_all("span.glyphicon-check").count
    end
    openAllVisibleNodes
    assert_equal 20, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    openAllVisibleNodes
    assert_equal 68, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    openAllVisibleNodes
    assert_equal 186, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count

    page.find("#main-container.trees #showAreas").click
    assert_equal 4, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showComponents").click
    assert_equal 20, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showOutcomes").click
    assert_equal 68, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showIndicators").click
    assert_equal 186, page.all('#tree .node-tree').count
    assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count

  end

  def clickArrayIds(ids)
    within('#tree') do
      ids.each do |id|
        icon = page.first("li[data-nodeid='#{id}'] .glyphicon-plus")
        icon.click if icon.present?
      end
    end
  end

  def openAllVisibleNodes
    idas = []
    tree_nodes = page.all('#tree .node-tree')
    tree_nodes.each do |n|
      idas << n['data-nodeid']
    end
    clickArrayIds(idas)
  end

end
