require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'
# require 'test_helper_debugging'


class TreesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @user1 = FactoryBot.create(:user, roles: 'admin')
    @user1.confirm # do a devise confirmation of new user
    sign_in @user1
    testing_db_tfv_seed
    @locale_code = 'en'
    I18n.locale = @locale_code
    @bio_upload = Upload.where(subject_id: @bio.id).first
  end

  test "should get index" do
    get trees_path
    assert_response :success
    assert_equal 0, assigns(:subjects).count
    assert_equal 13, assigns(:gbs).count
  end

  test "should get index_listing, added items are then listed" do
    post index_listing_trees_path
    assert_response :success
    assert_equal 0, assigns(:subjects).count
    assert_equal 13, assigns(:gbs).count
    assert_equal 0, assigns(:trees).count

    # don't need create action in controller thus far.
    # assert_difference('Tree.count', 1) do
    #   post trees_path, params: { tree: {
    #     tree_type_id: @otc.id,
    #     version_id: @v01.id,
    #     subject_id: @hem.id,
    #     grade_band_id: @gb_09.id,
    #     code: '1'
    #   } }
    # end
    # post index_listing_trees_path
    # assert_response :success
    # assert_equal 1, assigns(:trees).count
  end

  test "filter by grade_band works" do

    # load up the bio (all grade_bands) file
    up_file = fixture_file_upload('files/tfvV02BioAllEng.csv','text/csv')
    patch do_upload_upload_path(id: @bio_upload.id), params: {upload: {file: up_file}}
    assert_response :success
    assert_equal BaseRec::UPLOAD_DONE, assigns(:upload).status
    assert_equal 0, assigns(:errs).count
    assert_equal 56, Tree.count
    assert_equal 44, Tree.active.count

    # # OLD- load up the 13 file
    # up_file = fixture_file_upload('files/Hem_13_en.csv','text/csv')
    # patch do_upload_upload_path(id: @hem_13.id), params: {upload: {file: up_file}}
    # assert_response :success
    # assert_equal 2, assigns(:errs).count
    # assert_equal BaseRec::UPLOAD_SUBJ_RELATING, assigns(:upload).status
    # assert_equal 198, Tree.count # 186 + 9 + 4?

    # all returns all 56 records
    post index_listing_trees_path
    assert_response :success
    assert_equal 44, assigns(:trees).count

    # 09 returns 186 records
    post index_listing_trees_path, params: { tree: {
      subject_id: '',
      grade_band_id: @gb_09.id
    } }
    assert_response :success
    assert_equal 13, assigns(:trees).count

    # 13 returns all 9 records
    post index_listing_trees_path, params: { tree: {
      subject_id: '',
      grade_band_id: @gb_12.id
    } }
    assert_response :success
    assert_equal 9, assigns(:trees).count

  end

end
