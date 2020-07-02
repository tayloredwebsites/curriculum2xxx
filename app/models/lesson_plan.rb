class LessonPlan < BaseRec
  has_many :user_lesson_plans
  has_many :activities, :class_name => 'Activity'
  has_many :resource_joins, as: :resourceable
  has_many :resources, through: :resource_joins
  belongs_to :user, optional: true
  belongs_to :tree
  has_many :users, through: :user_lesson_plans

end