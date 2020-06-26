require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'
# require 'test_helper_debugging'

class SectorsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @user1 = FactoryBot.create(:user, roles: 'admin')
    @user1.confirm # do a devise confirmation of new user
    sign_in @user1
    Rails.logger.debug("+++ setup completed +++")
    testing_db_tfv_seed
    @bio = Subject.where(:code => 'bio').first
    @bio_upload = Upload.where(:subject_id => @bio.id).first
  end

  test "index listing filter should work" do
    # load up the bio file
    up_file = fixture_file_upload('files/tfvV02BioAllEng.csv','text/csv')
    patch do_upload_upload_path(id: @bio_upload.id), params: {phase: 1, upload: {file: up_file}}
    assert_response :success
    assert_equal BaseRec::UPLOAD_DONE, assigns(:upload).status
    assert_equal 0, assigns(:errs).count
    assert_equal 56, Tree.count
    puts "BIO REC: #{@bio.inspect}"
    puts "TREES CREATED: #{Tree.all.pluck("code").inspect}"

    # load up the 13 file
    # up_file = fixture_file_upload('files/Hem_13_en.csv','text/csv')
    # patch do_upload_upload_path(id: @hem_13.id), params: {upload: {file: up_file}}
    # assert_response :success
    # assert_equal BaseRec::UPLOAD_SUBJ_RELATING, assigns(:upload).status
    # assert_equal 2, assigns(:errs).count
    # assert_equal 198, Tree.count # 186 + 9 + 4 (?)

    get sectors_path
    assert_response :success
    # confirm select options have the right number of items
    assert_equal 13, assigns(:subjects).count
    assert_equal 0, assigns(:gbs).count
    assert_equal 10, assigns(:sectors).count

    post sectors_path, params: { tree: { subject_id: @hem.id } }
    assert_response :success
    assert_equal 135, assigns(:rptRows).count

    post sectors_path, params: { tree: { sector_id: @sector1.id } }
    assert_response :success
    assert_equal 11, assigns(:rptRows).count

    post sectors_path, params: { tree: { grade_band_id: @gb_09.id } }
    assert_response :success
    assert_equal 131, assigns(:rptRows).count

    post sectors_path, params: { tree: { subject_id: '', grade_band_id: '', sector_id: '' } }
    assert_response :success
    assert_equal 135, assigns(:rptRows).count


  end

end
