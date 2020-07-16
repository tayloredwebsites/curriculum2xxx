require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'
# require 'test_helper_debugging'

class UploadsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @user1 = FactoryBot.create(:user, roles: 'admin')
    @user1.confirm # do a devise confirmation of new user
    sign_in @user1
    testing_db_tfv_seed
    @bio_upload = Upload.where(:subject_id => @bio.id).first
    @bio_err_upload = Upload.where(:subject_id => @bio.id).third
  end

  test "should get uploads index" do
    get uploads_path
    assert_response :success
    puts "uploads count: #{Upload.all.count}"
    assert_equal 15, assigns(:uploads).count
  end

  test "should get uploads create fail with missing args" do
    assert_difference('Upload.count', 0) do
      post uploads_path, params: { upload: { subject_id: @bio.id } }
    end
  end

  test "should get uploads create" do
    assert_difference('Upload.count', 1) do
      post uploads_path, params: { upload: {
        subject_id: @bio.id,
        locale_id: @loc_en.id,
        grade_band_id: nil,
        status: BaseRec::UPLOAD_STATUS[BaseRec::UPLOAD_NOT_UPLOADED]
      } }
    end
  end

  test "should successfully start_upload of file" do
    get start_upload_upload_path(id: @bio_upload.id)
    assert_response :success
  end

  test "should successfully do_upload of good file" do
    assert_equal 'tfvv02BioAllEng.csv', @bio_upload.filename
    up_file = fixture_file_upload('files/tfvV02BioAllEng.csv','text/csv')
    patch do_upload_upload_path(id: @bio_upload.id), params: {phase: 1, upload: {file: up_file}}
    assert_response :success
    assert_equal BaseRec::UPLOAD_DONE, assigns(:upload).status
    assert_equal 0, assigns(:errs).count
    assert_equal 56, Tree.count
    assert_equal 29, Resource.count
    assert_equal 29, ResourceJoin.count
    assert_equal 1, ResourceJoin.where(:resourceable_type => 'Tree').count
    outc_resources = Outcome.first.resources
    outc_res_key = outc_resources.first.name_key
    assert_equal 1, outc_resources.count
    assert_equal 'explain', outc_resources.first.resource_code
    explain_str = "Examples of mathematical representations could include graphs, charts, histograms, and population changes gathered from simulations or historical data sets. Examples of classroom activities could include providing peer feedback on arguments about whether organisms would have the capacity to produce populations of great size were it not for the fact that environments and resources are finite, or defining problems related to carrying capacity in ecosystems."
    assert_equal explain_str, Translation.find_translation_name(@loc_en.code, outc_res_key, 'xxx')
  end


  ####
  # To Do: Errors and error reporting in do_upload for csv files
  # There should be some kind of error reporting when the upload
  # process aborts, but the lack of errors here is a reflection
  # of how the uploads process currently behaves
  ####
  test "should not finish uploading file with errors" do
    assert_equal 'tfvv02BioAllEngErrors.csv', @bio_err_upload.filename
    up_file = fixture_file_upload('files/tfvV02BioAllEngErrors.csv','text/csv')
    patch do_upload_upload_path(id: @bio_err_upload.id), params: {phase: 1, upload: {file: up_file}}
    assert_response :success
    assert_equal BaseRec::UPLOAD_NOT_UPLOADED, assigns(:upload).status
    assert_equal 0, assigns(:errs).count
    assert_equal 4, Tree.count
  end


end
