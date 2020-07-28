class LessonPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson_plan, only: [:show]
  before_action :find_lp_tree, only: [:show]
  before_action :find_user_for_joins, only: [:create]

  def new
    @lp_tree = Tree.find(lesson_plan_params[:tree_id])
    sequence = @lp_tree.lesson_plans.working.count + 1
    @lesson_plan = LessonPlan.new(
        sequence: sequence,
        tree_id: @lp_tree.id,
        base_key: "#{@lp_tree.base_key}.LP#{1000 + sequence}",
        is_exemplar: lesson_plan_params[:is_exemplar],
      )
    @user_lesson_plan = UserLessonPlan.new(
        user_id: user_lesson_plan_params[:user_id],
      )
    @translation = Translation.new
    respond_to do |format|
     format.html
     format.js { render 'shared/edit', :locals => {:edit_partial => 'lesson_plans/edit' } }
    end
  end


  def create
    ActiveRecord::Base.transaction do
      @lesson_plan = LessonPlan.create(lesson_plan_params)
      @translation = Translation.create(
          locale: @locale_code,
          key: @lesson_plan.name_key,
          value: translation_params[:value]
        )
      @user_for_joins.lesson_plans << @lesson_plan
    end
    respond_to do |format|
     format.js { render 'shared/update' }
    end
  end


  def show
    body = { user: { email: current_user.email} }
    token = JWT.encode({email: current_user.email}, JWT_PASSWORD)
    begin
      response = HTTParty.get('http://localhost:3006/api/v1/tracker_pages', body: token).parsed_response
      @sections = response['sections']
    rescue
    end
    @sections = [] if @sections.nil?

    @editMe = (params[:editme] == @lesson_plan.id.to_s)
    translKeys = [@lesson_plan.name_key]
    @detailTables = Hash.new { |h, k| h[k] = [] }
    @detailTables[:headers] << @lesson_plan.build_header_table
    @detailTables[:headers] << UserLessonPlan.build_header_table(@lesson_plan.users)
    if @lp_tree
      @detailTables[:headers] << @lp_tree.build_header_table(@hierarchies)
      translKeys << @lp_tree.name_key
    end

    joins = @lesson_plan.resource_joins
    resourcesByCode = Hash.new { |h, k| h[k] = [] }
    Resource.where(id: joins.pluck('resource_id').uniq).each { |r| resourcesByCode[r.resource_code] << r }

    table, keys = Resource.build_generic_table(
      @treeTypeRec,
      @versionRec,
      ['objective', 'evid_achievement', 'lesson_start'],  #resource_code,
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
      ['lesson_closure', 'reflections'],  #resource_code,
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


  def make_exemplar
    unauthorized() and return if !can?(:create, LessonPlan.new(is_exemplar: true))
    @working_lp = LessonPlan.find(lesson_plan_params[:id])
    @lp_tree = @working_lp.tree
    @lesson_plan = nil
    ActiveRecord::Base.transaction do

      @lesson_plan = LessonPlan.create(
          tree_id: @working_lp.tree_id,
          sequence: @lp_tree.lesson_plans.exemplar.count + 1,
          base_key: "#{@working_lp.base_key}.exemplar",
          is_exemplar: true,
          exemplar_authorizor_id: current_user.id,
          gd_owner_email: @working_lp.gd_owner_email,
          in_portfolio: @working_lp.in_portfolio,
        )
      Translation.copy_translations_for_key(@working_lp.name_key, @lesson_plan.name_key)
      @working_lp.users.each { |user| @lesson_plan.users << user }

      resource_ids = @working_lp.resource_joins.pluck('resource_id').uniq

      @lesson_plan.clone_and_join_resources(Resource.where(id: resource_ids), nil)

      @working_lp.activities.each { |activity| @lesson_plan.clone_and_join_activity(activity, nil) }

    end #Transaction

    if @lesson_plan && @lesson_plan.id
      redirect_to lesson_plan_path({id: @lesson_plan.id})
    else
      flash[:notice] = 'failed to save exemplar version of lesson plan'
      redirect_to lesson_plan_path({id: @working_lp.id})
    end

  end


  private

    def lesson_plan_params
      if params[:lesson_plan]
        params.require(:lesson_plan).permit(
          :id,
          :tree_id,
          :sequence,
          :base_key,
          :is_exemplar,
        )
      else
       nil
      end
    end

    def user_lesson_plan_params
      if params[:user_lesson_plan]
        params.require(:user_lesson_plan).permit(
          :id,
          :user_id,
        )
      else
       nil
      end
    end

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

    def find_user_for_joins
      @user_for_joins = User.find(user_lesson_plan_params[:user_id]) if user_lesson_plan_params
    end
end