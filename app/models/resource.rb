class Resource < BaseRec
  has_many :resource_joins
  has_many :user_resources
  belongs_to :resourceable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  has_many :users, through: :user_resources

  has_many :trees, through: :resource_joins, source: :resourceable, source_type: 'Tree'
  has_many :outcomes, through: :resource_joins, source: :resourceable, source_type: 'Outcome'
  has_many :dimensions, through: :resource_joins, source: :resourceable, source_type: 'Dimension'
end