require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'

class TreesSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user)
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "Trees (Curriculum) index page" do
    visit trees_url
    # uploads index page
    assert_equal("/trees", current_path)
    # to do - use translation when title is translated
    assert_equal I18n.translate('trees.index.name'), page.title
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal("/trees/index_listing", current_path)
    # to do - use translation when title is translated
    assert_equal I18n.translate('trees.index.name'), page.title
    assert_equal 0, page.all('#tree .node-tree').count
  end

  test "Test curriculum from uploaded file" do
    load_curriculum_file
    # good_upload_check_curriculum
    good_detail_page
  end

  def load_curriculum_file
    visit uploads_url
    # uploads index page
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
  end


  def good_upload_check_curriculum
    visit trees_url
    # uploads index page
    assert_equal("/trees", current_path)

    # list all grade levels (9 & 13)
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal("/trees/index_listing", current_path)
    assert_equal 4, page.all('#tree .node-tree').count
    # if we want checkboxes
    # within("#tree li[data-nodeid='0']") do
    #   # ensure user can check and uncheck checkbox
    #   assert_equal 1, page.find_all("span.glyphicon-unchecked").count
    #   assert_equal 0, page.find_all("span.glyphicon-check").count
    #   page.find("span.glyphicon-unchecked").click
    #   assert_equal 0, page.find_all("span.glyphicon-unchecked").count
    #   assert_equal 1, page.find_all("span.glyphicon-check").count
    #   page.find("span.glyphicon-check").click
    #   assert_equal 1, page.find_all("span.glyphicon-unchecked").count
    #   assert_equal 0, page.find_all("span.glyphicon-check").count
    # end
    openAllVisibleNodes(2)
    assert_equal 12, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    openAllVisibleNodes(3)
    assert_equal 19, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    openAllVisibleNodes(4)
    assert_equal 21, page.all('#tree .node-tree').count
    openAllVisibleNodes(5)
    assert_equal 24, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showAreas").click
    assert_equal 4, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showComponents").click
    # 4 Area rows plus 16 Component Rows
    assert_equal 20, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showOutcomes").click
    # 20 Area & Component rows + 48 Outcome rows
    assert_equal 68, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showIndicators").click
    # 186 Area, Component, Outcome rows,  plus 48 grade band rows, plus 118 Indicator rows
    assert_equal 234, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count

    # list grade level 9
    select('9', from: "tree_grade_band_id")
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal("/trees/index_listing", current_path)
    assert_equal 4, page.all('#tree .node-tree').count
    # if we want checkboxes
    # within("#tree li[data-nodeid='0']") do
    #   # ensure user can check and uncheck checkbox
    #   assert_equal 1, page.find_all("span.glyphicon-unchecked").count
    #   assert_equal 0, page.find_all("span.glyphicon-check").count
    #   page.find("span.glyphicon-unchecked").click
    #   assert_equal 0, page.find_all("span.glyphicon-unchecked").count
    #   assert_equal 1, page.find_all("span.glyphicon-check").count
    #   page.find("span.glyphicon-check").click
    #   assert_equal 1, page.find_all("span.glyphicon-unchecked").count
    #   assert_equal 0, page.find_all("span.glyphicon-check").count
    # end
    openAllVisibleNodes(2)
    assert_equal 12, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    openAllVisibleNodes(3)
    assert_equal 19, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    openAllVisibleNodes(4)
    assert_equal 23, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showAreas").click
    assert_equal 4, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showComponents").click
    assert_equal 20, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showOutcomes").click
    assert_equal 68, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
    page.find("#main-container.trees #showIndicators").click
    assert_equal 186, page.all('#tree .node-tree').count
    # assert_equal 1, page.find_all("#tree li[data-nodeid='0'] span.glyphicon-unchecked").count
  end

  def good_detail_page
    visit trees_url
    assert_equal("/trees", current_path)
    # list all grade levels (9 & 13)
    page.find("form.new_tree input[type='submit']").click
    assert_equal("/trees/index_listing", current_path)
    page.find("#main-container.trees #showIndicators").click
    assert_equal 234, page.all('#tree .node-tree').count
    page.find("li[data-nodeid='4'] a").click
    within('.area-row') { assert page.has_content?('Area 1: MATTER'), 'missing matching area row' }
    within('.component-row') { assert page.has_content?('Component 1: Structure and property of matter'), 'missing matching component row' }
    within('.outcome-row') { assert page.has_content?('Outcome 1: differentiates composition and type of matter'), 'missing matching outcome row' }
    within('.indicator-col') { assert page.has_content?("1.1.1.a: Indicator a:"), 'missing indicator' }
    within('.rel-sectors') { assert page.has_content?("3 - "), 'missing related sector' }
    # within('rel-sector-col') { assert page.has_content?(""), '' }
    # within('rel-sector-col') { assert page.has_content?(""), '' }
    # within('rel-sector-col') { assert page.has_content?(""), '' }
  end


  def openAllVisibleNodes(limit)
    idas = []
    tree_nodes = page.all('#tree .node-tree')
    counter = 0
    tree_nodes.each do |n|
      idas << n['data-nodeid']
      counter += 1
      break if counter + 1 > limit
    end
    clickArrayIds(idas)
  end


  def clickArrayIds(ids)
    within('#tree') do
      ids.each do |id|
        icon = page.first("li[data-nodeid='#{id}'] .glyphicon-plus")
        icon.click if icon.present?
      end
    end
  end


end
