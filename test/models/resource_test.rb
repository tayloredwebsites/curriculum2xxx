require 'helpers/test_components_helper'
require 'helpers/seeds_testing_helper'
# require 'test_helper_debugging'

include SeedsTestingHelper

class ResourceTest < ActiveSupport::TestCase

  setup do
    testing_db_tfv_seed
    @resource_1 = Resource.create()
    @user_1 = FactoryBot.create(:user)
    ###############
    #Resourcables:
    @outcome_1 = Outcome.create(base_key: '1.1.test.outc')
    @tree_1 = Tree.create(tree_type: @ttTFV, version: @verTFV, subject: @bio, grade_band: @gb_09, code: '1', base_key: '1')
    @tree_2 = Tree.create(tree_type: @ttTFV, version: @verTFV, subject: @bio, grade_band: @gb_09, code: '1.1', base_key: '1.1')
    @tree_3 = Tree.create(tree_type: @ttTFV, version: @verTFV, subject: @bio, grade_band: @gb_09, outcome: @outcome, code: '1.1.test', base_key: '1.1.test')
    @dimension_1 = Dimension.create()
    ########
  end

  test "Should be able to join resources and users, without reference to a resourceable" do
    @resource_1.users << @user_1
    assert_equal 1, UserResource.count
    assert_equal @user_1.id, UserResource.first.user_id
    assert_equal @resource_1.id, UserResource.first.resource_id
    assert_nil UserResource.first.user_resourceable_id
  end

  test "Should be able to join resources and users, with reference to a resourceable" do
    UserResource.create(user: @user_1, resource: @resource_1, user_resourceable: @outcome_1)
    assert_equal 1, UserResource.count
    assert_equal UserResource.first.user_resourceable.id, @outcome_1.id
    assert_equal @user_1.id, UserResource.first.user_id
    assert_equal @resource_1.id, UserResource.first.resource_id
    UserResource.create(user: @user_1, resource: @resource_1, user_resourceable: @tree_1)
    UserResource.create(user: @user_1, resource: @resource_1, user_resourceable: @tree_2)
    UserResource.create(user: @user_1, resource: @resource_1, user_resourceable: @tree_3)
    UserResource.create(user: @user_1, resource: @resource_1, user_resourceable: @dimension_1)
    assert_equal 5, UserResource.count
    assert_equal 1, @user_1.resources.distinct.count
    assert_equal 3, UserResource.where(user_resourceable_type: "Tree").count
  end

  test "Should be able to join Resources and Resourceable curriculum items" do
    @tree_1.resources << @resource_1
    @resource_1.trees << @tree_2
    ResourceJoin.create(resource: @resource_1, resourceable: @tree_3)
    @resource_1.dimensions << @dimension_1
    @resource_1.outcomes << @outcome_1
    assert_equal 1, @outcome_1.resources.count
    assert_equal 1, @dimension_1.resources.count
    # resourceable.resources should not include user_resources
    #   this is because we plan to get published/reviewed resources
    #   and private/"my" resources differently:
    #   @reviewed_resources = @tree.resources
    #   @my_tree_resources = UserResource.where(
    #     :user_id => my_id,
    #     :user_resourcable_type => 'Tree',
    #     :user_resourceable_id => @tree.id
    #   )
    UserResource.create(user: @user_1, resource: @resource_1, user_resourceable: @tree_1)
    assert_equal 1, @tree_1.resources.count #expect 1, not 2
    assert_equal 3, @resource_1.trees.count #expect 3, not 4
  end

end
