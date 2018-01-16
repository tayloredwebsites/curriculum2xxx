require 'helpers/test_system_helper'
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


  test "good upload" do
    visit uploads_url

    # uploads index page
    assert_equal("/uploads", current_path)
    # choose the chemistry grade band 9 english upload
    # to do - use translation when title is translated
    assert_equal 'Uploads Listing', page.title
    assert_equal 2, page.all('#uploadsTable tbody tr').count
    page.find("#uploadsTable tbody tr#id_#{@hem_09.id} a").click

    # chemistry grade band 9 english upload page, with status not uploaded
    assert_equal("/uploads/#{@hem_09.id}/start_upload", current_path)
    # do upload
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_09.status)
    assert_equal(0, Tree.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click

    # at upload reporting page
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    refute_equal(0, Tree.count)
    # confirm
    # 4 area records were added
    # 16 components (4 per area +(4*4 = 16)
    # 48 outcomes (avg. 3 per component)
    assert_equal(186, Tree.where(parent_id: nil).count)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_TREE_UPLOADED, @hem_09.status)
    # confirm number of records returned is 4 (4 area records)
    rpt_rows = page.find_all('#uploadReport tbody tr .colStatusMsg')
    assert_equal rpt_rows.count, 305 # 186 tree items + 119 KBE report records
    # countTreeRecs = 0
    # countKbeRecs = 0
    # rpt_rows.each do |r|
    #   # assert r.text == 'Code Added Text Added' || r.text == 'Related to KBE'
    #   assert r.text == 'Code Added Text Added' || r.text == BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_KBE_RELATED]
    #   countTreeRecs += 1 if r.text == 'Code Added Text Added'
    #   countKbeRecs += 1 if r.text == BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_KBE_RELATED]
    # end
    # assert_equal countTreeRecs, 186
    # assert_equal countKbeRecs, 119
    assert_equal 0, page.find_all('div.error').count


    # run it again, and should have the same report
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_09.id}/do_upload", current_path)
    @hem_09.reload
    assert_equal(BaseRec::UPLOAD_TREE_UPLOADED, @hem_09.status)
    assert_equal 305, page.find_all('#uploadReport tbody tr').count
    assert_equal 0, page.find_all('div.error').count

    good_upload_check_curriculum
  end


  def good_upload_check_curriculum
    visit trees_url
    # uploads index page
    assert_equal("/trees", current_path)
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

  test "errors upload" do
    visit uploads_url

    # uploads index page
    assert_equal("/uploads", current_path)
    # to do - use translation when title is translated
    assert_equal 'Uploads Listing', page.title
    assert_equal 2, page.all('#uploadsTable tbody tr').count
    page.find("#uploadsTable tbody tr#id_#{@hem_13.id} a").click

    # uploads page, with status not uploaded
    assert_equal("/uploads/#{@hem_13.id}/start_upload", current_path)
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end

    # do upload invalid filename
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_13.status)
    assert_equal(0, Tree.count)
    assert_equal(40, Translation.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_09_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_13.id}/do_upload", current_path)
    assert page.has_content?(I18n.translate('app.errors.incorrect_filename', filename: @hem_13.filename))
    assert_equal 'Uploads Listing', page.title
    assert_equal(0, Tree.count)

    # do upload invalid file
    page.find("#uploadsTable tbody tr#id_#{@hem_13.id} a").click
    assert_equal("/uploads/#{@hem_13.id}/start_upload", current_path)
    within('h4') do
      assert page.has_content?("Status: #{BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]}")
    end
    assert_equal(BaseRec::UPLOAD_NOT_UPLOADED, @hem_13.status)
    assert_equal(0, Tree.count)
    page.find('#upload_file').set(Rails.root.join('test/fixtures/files/Hem_13_transl_Eng.csv'))
    find('button').click
    assert_equal("/uploads/#{@hem_13.id}/do_upload", current_path)

    assert_equal(9, Tree.count)
    rows =  page.find_all('#uploadReport tbody tr')
    assert_equal 19, rows.count
    assert_equal(49, Translation.count)  # translations for nine items added to tree
    assert_equal 5, page.find_all('div.error').count # row for each of four error rows and count row
  end


  def clickArrayIds(ids)
    within('#tree') do
      ids.each do |id|
        icon = page.first("li[data-nodeid='#{id}'] .glyphicon-plus")
        icon.click if icon.present?
      end
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


end
