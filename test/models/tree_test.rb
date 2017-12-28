require 'test_helper'
require 'helpers/seeds_testing_helper'

include SeedsTestingHelper

class TreeTest < ActiveSupport::TestCase

  setup do
    testing_db_seeds
  end

  test "tree missing code should fail" do
    tree = Tree.new()
    tree.tree_type_id = @otc.id
    tree.version_id = @v01.id
    tree.subject_id = @hem.id
    tree.grade_band_id = @gb_09.id
    tree.code = nil
    refute tree.valid?, 'missing tree code should not be valid'
  end

  test "tree with blank code should fail" do
    tree = Tree.new()
    tree.tree_type_id = @otc.id
    tree.version_id = @v01.id
    tree.subject_id = @hem.id
    tree.grade_band_id = @gb_09.id
    tree.code = ""
    refute tree.valid?, 'blank tree code should not be valid'
  end

  test "tree without grade_band should fail" do
    tree = Tree.new()
    tree.tree_type_id = @otc.id
    tree.version_id = @v01.id
    tree.subject_id = @hem.id
    # tree.grade_band_id = @gb_09.id
    tree.code = "1"
    refute tree.valid?, 'missing tree grade_band should not be valid'
  end

  test "tree without subject should fail" do
    tree = Tree.new()
    tree.tree_type_id = @otc.id
    tree.version_id = @v01.id
    # tree.subject_id = @hem.id
    tree.grade_band_id = @gb_09.id
    tree.code = "1"
    refute tree.valid?, 'missing tree subject should not be valid'
  end

  test "tree without version should fail" do
    tree = Tree.new()
    tree.tree_type_id = @otc.id
    # tree.version_id = @v01.id
    tree.subject_id = @hem.id
    tree.grade_band_id = @gb_09.id
    tree.code = "1"
    refute tree.valid?, 'missing tree version should not be valid'
  end

  test "tree without tree_type should fail" do
    tree = Tree.new()
    # tree.tree_type_id = @otc.id
    tree.version_id = @v01.id
    tree.subject_id = @hem.id
    tree.grade_band_id = @gb_09.id
    tree.code = "1"
    refute tree.valid?, 'missing tree tree_type should not be valid'
  end

  test "tree with all fields should pass" do
    tree = Tree.new()
    tree.tree_type_id = @otc.id
    tree.version_id = @v01.id
    tree.subject_id = @hem.id
    tree.grade_band_id = @gb_09.id
    tree.code = "1"
    assert tree.valid?, 'all fields supplied to tree should be valid'
  end

  test "find_or_add_code_in_tree tests" do
    # should add area 2
    tree_count = Tree.count
    new_code, match_rec, status, msg = Tree.find_or_add_code_in_tree( @otc.id, @v01.id, @hem.id, @gb_09.id, '2', nil, nil)
    assert_equal tree_count+1, Tree.count

    # should not add area 2 again
    tree_count = Tree.count
    new_code, match_rec, status, msg = Tree.find_or_add_code_in_tree( @otc.id, @v01.id, @hem.id, @gb_09.id, '2', nil, nil)
    assert_equal tree_count, Tree.count
    assert_equal ApplicationRecord::SAVE_STATUS_NO_CHANGE, status

    # should skip if matching record passed in
    tree_count = Tree.count
    new_code, match_rec, status, msg = Tree.find_or_add_code_in_tree( @otc.id, @v01.id, @hem.id, @gb_09.id, '2', nil, match_rec)
    assert_equal tree_count, Tree.count
    assert_equal ApplicationRecord::SAVE_STATUS_SKIP, status

  end
end
