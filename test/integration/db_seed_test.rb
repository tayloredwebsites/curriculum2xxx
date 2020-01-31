require 'helpers/test_components_helper'
# require 'test_helper_debugging'

class DbSeedTest < ActionDispatch::IntegrationTest
  # include Devise::Test::IntegrationHelpers

  setup do
    load "#{Rails.root}/db/seeds.rb"
  end

  test "confirm db_seed properly loads all tables" do
    assert_equal(1, Version.count)
    assert_equal(3, Locale.count)
  end

end
