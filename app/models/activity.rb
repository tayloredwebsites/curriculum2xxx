class Activity < BaseRec
  belongs_to :lesson_plan
  has_many :activity_dimensions
  has_many :dimensions, through: :activity_dimensions
  belongs_to :dimension, optional: true
  has_many :resource_joins, as: :resourceable
  has_many :resources, through: :resource_joins
end