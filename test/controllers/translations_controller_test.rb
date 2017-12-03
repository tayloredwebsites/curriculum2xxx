require 'test_helper'

class TranslationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get translations_index_url
    assert_response :success
  end

  test "should get new" do
    get translations_new_url
    assert_response :success
  end

  test "should get create" do
    get translations_create_url
    assert_response :success
  end

  test "should get edit" do
    get translations_edit_url
    assert_response :success
  end

  test "should get update" do
    get translations_update_url
    assert_response :success
  end

end
