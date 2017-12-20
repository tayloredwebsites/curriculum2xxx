require 'test_helper'
require 'helpers/seeds_testing_helper'


class UploadsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @user1 = FactoryBot.create(:user)
    @user1.confirm # do a devise confirmation of new user
    sign_in @user1
    Rails.logger.debug("+++ setup completed +++")
    testing_db_seeds
  end

  test "should get uploads index" do
    get uploads_url
    assert_response :success
    assert_equal 1, assigns(:uploads).count
  end

  test "should get uploads create fail with missing args" do
    assert_difference('Upload.count', 0) do
      post uploads_url, params: { upload: { subject_id: @hem.id } }
    end
  end

  test "should get uploads create" do
    assert_difference('Upload.count', 1) do
      post uploads_url, params: { upload: {
        subject_id: @hem.id,
        grade_band_id: @gb_09.id,
        locale_id: @loc_en.id,
        status: Upload::UPLOAD_STATUS[Upload::UPLOAD_STATUS_NOT_UPLOADED]
      } }
    end
  end

end
