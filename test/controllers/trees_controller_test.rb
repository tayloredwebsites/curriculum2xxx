require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'


class TreesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @user1 = FactoryBot.create(:user, roles: 'admin')
    @user1.confirm # do a devise confirmation of new user
    sign_in @user1
    Rails.logger.debug("+++ setup completed +++")
    testing_db_seeds
  end

  test "should get index" do
    get trees_path
    assert_response :success
    assert_equal 6, assigns(:subjects).count
    assert_equal 4, assigns(:gbs).count
  end

  test "should get index_listing, added items are then listed" do
    post index_listing_trees_path
    assert_response :success
    assert_equal 6, assigns(:subjects).count
    assert_equal 4, assigns(:gbs).count
    assert_equal 0, assigns(:trees).count

    assert_difference('Tree.count', 1) do
      post trees_path, params: { tree: {
        tree_type_id: @otc.id,
        version_id: @v01.id,
        subject_id: @hem.id,
        grade_band_id: @gb_09.id,
        code: '1'
      } }
    end
    post index_listing_trees_path
    assert_response :success
    assert_equal 1, assigns(:trees).count
  end

  test "filter by grade_band works" do

    # load up the 09 file
    up_file = fixture_file_upload('files/Hem_09_transl_Eng.csv','text/csv')
    patch do_upload_upload_path(id: @hem_09.id), params: {upload: {file: up_file}}
    assert_response :success
    assert_equal BaseRec::UPLOAD_SECTOR_RELATED, assigns(:upload).status
    assert_equal 0, assigns(:errs).count
    assert_equal 186, Tree.count

    # load up the 13 file
    up_file = fixture_file_upload('files/Hem_13_transl_Eng.csv','text/csv')
    patch do_upload_upload_path(id: @hem_13.id), params: {upload: {file: up_file}}
    assert_response :success
    assert_equal BaseRec::UPLOAD_TREE_UPLOADING, assigns(:upload).status
    assert_equal 4, assigns(:errs).count
    assert_equal 195, Tree.count # 186 + 9

    # all returns all 195 records
    post index_listing_trees_path
    assert_response :success
    assert_equal 195, assigns(:trees).count

    # 09 returns 186 records
    post index_listing_trees_path, params: { tree: {
      subject_id: '',
      grade_band_id: @gb_09.id
    } }
    assert_response :success
    assert_equal 186, assigns(:trees).count

    # 13 returns all 9 records
    post index_listing_trees_path, params: { tree: {
      subject_id: '',
      grade_band_id: @gb_13.id
    } }
    assert_response :success
    assert_equal 9, assigns(:trees).count

  end

end
