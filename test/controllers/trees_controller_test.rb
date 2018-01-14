require 'helpers/test_controllers_helper'
require 'helpers/seeds_testing_helper'


class TreesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @user1 = FactoryBot.create(:user)
    @user1.confirm # do a devise confirmation of new user
    sign_in @user1
    Rails.logger.debug("+++ setup completed +++")
    testing_db_seeds
  end

  test "should get index" do
    get trees_url
    assert_response :success
    assert_equal 1, assigns(:subjects).count
    assert_equal 1, assigns(:gbs).count
  end

  test "should get index_listing, added items are then listed" do
    post index_listing_trees_url
    assert_response :success
    assert_equal 1, assigns(:subjects).count
    assert_equal 1, assigns(:gbs).count
    assert_equal 0, assigns(:trees).count

    assert_difference('Tree.count', 1) do
      post trees_url, params: { tree: {
        tree_type_id: @otc.id,
        version_id: @v01.id,
        subject_id: @hem.id,
        grade_band_id: @gb_09.id,
        code: '1'
      } }
    end

    post index_listing_trees_url
    assert_response :success
    assert_equal 1, assigns(:trees).count

  end

end
