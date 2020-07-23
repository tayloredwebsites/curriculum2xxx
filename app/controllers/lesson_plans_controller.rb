class LessonPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson_plan, only: [:show]
  before_action :find_lp_tree, only: [:show]

  def show
    @editMe = (params[:editme] == @lesson_plan.id.to_s)
    translKeys = [@lesson_plan.name_key]
    @detailTables = Hash.new { |h, k| h[k] = [] }
    @detailTables[:headers] << @lesson_plan.build_header_table
    @detailTables[:headers] << UserLessonPlan.build_header_table(@lesson_plan.users)
    if @lp_tree
      @detailTables[:headers] << @lp_tree.build_header_table(@hierarchies)
      translKeys << @lp_tree.name_key
    end

    joins = @lesson_plan.is_exemplar ? @lesson_plan.resource_joins : @lesson_plan.user_resources
    resourcesByCode = Hash.new { |h, k| h[k] = [] }
    Resource.where(id: joins.pluck('resource_id').uniq).each { |r| resourcesByCode[r.resource_code] << r }

    table, keys = Resource.build_generic_table(
      @treeTypeRec,
      @versionRec,
      ['objective', 'evid_achievement'],  #resource_code,
      @lesson_plan,
      joins,
      resourcesByCode,
      (@lesson_plan.is_exemplar ? nil : current_user),
    )
    @detailTables[:body] << table
    translKeys.concat(keys)

    #@lesson_plan.activities.order('sequence')
    table, keys = @lesson_plan.build_activities_tables(
      @treeTypeRec,
      @versionRec,
      (@lesson_plan.is_exemplar ? nil : current_user),
    )
    @detailTables[:body] << table
    translKeys.concat(keys)

    table, keys = Resource.build_generic_table(
      @treeTypeRec,
      @versionRec,
      ['reflections'],  #resource_code,
      @lesson_plan,
      joins,
      resourcesByCode,
      (@lesson_plan.is_exemplar ? nil : current_user),
    )
    @detailTables[:body] << table
    translKeys.concat(keys)



    @translations = Translation.translationsByKeys(
      @locale_code,
      translKeys
    )
  end



  private

    def translation_params
      if params[:translation]
        params.require(:translation).permit(
          :id,
          :key,
          :value,
          :locale,
        )
      else
       nil
      end
    end

    def find_lesson_plan
      @lesson_plan = LessonPlan.find(params[:id])
    end

    def find_lp_tree
      @lp_tree = Tree.find @lesson_plan.tree_id if @lesson_plan.tree_id
    end
end