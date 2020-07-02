class UserLessonPlan < BaseRec
  belongs_to :lesson_plan
  belongs_to :user
end