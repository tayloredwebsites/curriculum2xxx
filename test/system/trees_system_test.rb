require 'helpers/test_system_helper'
require 'helpers/seeds_testing_helper'

class TreesSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include SeedsTestingHelper

  setup do
    @one = create(:user)
    @one.confirm
    sign_in @one
    testing_db_seeds
  end

  test "Trees (Curriculum) index page" do
    visit trees_url
    # uploads index page
    assert_equal("/trees", current_path)
    # to do - use translation when title is translated
    assert_equal I18n.translate('trees.index.name'), page.title
    page.find("form.new_tree input[type='submit']").click
    # uploads page, with status not uploaded
    assert_equal("/trees/index_listing", current_path)
    # to do - use translation when title is translated
    assert_equal I18n.translate('trees.index.name'), page.title
    assert_equal 0, page.all('#tree .node-tree').count
  end

end
