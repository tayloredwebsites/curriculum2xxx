class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson_plan, only: [:new]

  def new
    @activity = Activity.new(
        lesson_plan_id: activity_params[:lesson_plan_id],
        sequence: (@lesson_plan.activities.count + 1),
      )
    respond_to do |format|
     format.html
     format.js { render 'shared/edit', :locals => {:edit_partial => 'activities/edit' } }
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @activity = Activity.create(
          lesson_plan_id: activity_params[:lesson_plan_id],
          sequence: activity_params[:sequence],
        )
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


  private

    def activity_params
      if params[:activity]
        params.require(:activity).permit(
          :lesson_plan_id,
          :sequence,
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

end