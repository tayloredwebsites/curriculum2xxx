class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson_plan, only: [:new]
  before_action :find_activity, only: [:edit, :update]
  before_action :populate_dropdowns, only: [:new, :edit]

  def new
    @activity = Activity.new(
        lesson_plan_id: activity_params[:lesson_plan_id],
        sequence: (@lesson_plan.activities.count + 1),
      )
    @name_translation = Translation.new

    respond_to do |format|
     format.html
     format.js { render 'shared/edit', :locals => {:edit_partial => 'activities/edit' } }
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @activity = Activity.create(activity_params)
      @translation = Translation.create(
          locale: @locale_code,
          key: @activity.name_key,
          value: translation_params[:value]
        )
    end
    respond_to do |format|
     format.js { render 'shared/update' }
    end
  end

  def edit
    respond_to do |format|
     format.html
     format.js { render 'shared/edit', :locals => {:edit_partial => 'activities/edit' } }
    end
  end

  def update
    @activity.update(activity_params)
    @name_translation.update(translation_params)
    respond_to do |format|
     format.js { render 'shared/update' }
    end
  end

  private

    def activity_params
      if params[:activity]
        params.require(:activity).permit(
          :lesson_plan_id,
          :sequence,
          :teach_strat,
          :student_org,
          :time_min,
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
      if activity_params && activity_params[:lesson_plan_id]
        @lesson_plan = LessonPlan.find(activity_params[:lesson_plan_id])
      end
    end

    def find_activity
      @activity = Activity.find(params[:id])
      find_name_translation
    end

    def find_name_translation
      @name_translation = Translation.where(
          locale: @locale_code,
          key: @activity.name_key,
        ).first || Translation.new(
          locale: @locale_code,
          key: @activity.name_key,
        )
    end

    def populate_dropdowns
      translKeys = []
      @dropdown_tables = {}
      ['teach_strat', 'student_org'].each do |table_name|
        opts, keys = LookupTablesOption.get_table_array_and_keys(
          @treeTypeRec.code,
          @versionRec.code,
          table_name
        )
        @dropdown_tables[:"#{table_name}"] = opts
        translKeys.concat(keys)
      end

      @translations = Translation.translationsByKeys(
        @locale_code,
        translKeys
      )
    end

end