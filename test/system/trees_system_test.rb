require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'

class TreesSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user, roles: 'admin')
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "Trees (Curriculum) index page" do
    # nav to trees index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    # assert_equal "/users/lang/en", current_path
    # assert_equal home_users_path("en"), current_path
    page.find("#topNav a[href='/en/trees']").click
    sleep 1
    assert_equal(trees_path('en'), current_path)
    # at trees index page
    assert_equal I18n.translate('trees.index.name', locale: 'en'), page.title
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal(index_listing_trees_path('en'), current_path)
    assert_equal I18n.translate('trees.index.name', locale: 'en'), page.title
    assert_equal 0, page.all('#tree .node-tree').count

  end

  test "Test curriculum from uploaded file" do
    load_curriculum_file
    # good_upload_check_curriculum
    good_detail_page
  end

  def load_curriculum_file
    visit uploads_path
    # uploads index page
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
  end


  def good_upload_check_curriculum
    # nav to trees index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    # assert_equal "/users/lang/en", current_path
    assert_equal home_users_path("en"), current_path
    page.find("#topNav a[href='/en/trees']").click
    assert_equal(trees_path('en'), current_path)
    # at trees index page
    assert_equal I18n.translate('trees.index.name', locale: 'en'), page.title

    # list all grade levels (9 & 13)
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal(index_listing_trees_path('bs'), current_path)
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
    assert_equal(index_listing_trees_path('bs'), current_path)
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
    # nav to trees index page
    visit root_path
    page.find("ul#locale-select a[href='/users/lang/en']").click
    # assert_equal "/users/lang/en", current_path
    # assert_equal home_users_path("en"), current_path
    page.find("#topNav a[href='/en/trees']").click
    sleep 1
    assert_equal(trees_path('en'), current_path)
    # at trees index page
    assert_equal I18n.translate('trees.index.name', locale: 'en'), page.title
    select('Hem', from: 'tree_subject_id')
    # list all grade levels (9 & 13)
    page.find("form.new_tree input[type='submit']").click
    assert_equal(index_listing_trees_path('en'), current_path)
    page.find("#main-container.trees #showIndicators").click
    assert_equal 234, page.all('#tree .node-tree').count
    page.find("li[data-nodeid='4'] a").click
    within('.area-row') { assert page.has_content?('Area 1: Structure and property of matter'), 'missing matching area row' }
    within('.component-row') { assert page.has_content?('Component 1: differentiates composition and type of matter'), 'missing matching component row' }
    within('.outcome-row') { assert page.has_content?('Outcome 1: ["Distinguishes between pure matter (atoms and molecules) and mixtures (homogenous and heterogeneous)"]'), 'missing matching outcome row' }
    within('.indicator-name') { assert page.has_content?("Indicator 1.1.1.a: [\"Distinguishes between pure matter (atoms and molecules) and mixtures (homogenous and heterogeneous)\"]"), 'missing indicator' }
    assert_equal 'Knowing properties of materials is a basis for modern production of materials', page.find('.rel-reason-col.val').text
    within('.rel-sector-col.val') do
      assert page.has_content?("3 - Technology of materials")
      # link to related sector(s) work
      assert_equal 1, page.find_all("a[data-sector='#{@sector3.id}']").count
      page.find("a[data-sector='#{@sector3.id}']").click
    end
    assert_equal sectors_path('en'), current_path
    within("table.tree-listing tbody tr[data-row='0']") do
      assert page.has_content? "3 - Technology of materials"
    end
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
