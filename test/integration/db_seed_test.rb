require 'test_helper'

class DbSeedTest < ActionDispatch::IntegrationTest
  # include Devise::Test::IntegrationHelpers

  setup do
    load "#{Rails.root}/db/seeds.rb"
  end

  test "confirm db_seed properly loads all tables" do
    assert_equal(1, Version.count)
    assert_equal(1, TreeType.count)
    assert_equal(4, Locale.count)
    assert_equal(1, GradeBand.count)
    assert_equal(1, Subject.count)
    assert_equal(1, Upload.count)
  end

end