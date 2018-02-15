module UploadDataTestHelper

  def load_curriculum_file_hem09
    visit uploads_path
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
    assert_equal 390, page.find_all('#uploadReport tbody tr').count
    assert_equal 0, page.find_all('div.error').count
  end


end
