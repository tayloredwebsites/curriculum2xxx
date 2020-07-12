class Resource < BaseRec
  has_many :resource_joins
  has_many :user_resources
  belongs_to :resourceable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  has_many :users, through: :user_resources

  has_many :trees, through: :resource_joins, source: :resourceable, source_type: 'Tree'
  has_many :outcomes, through: :resource_joins, source: :resourceable, source_type: 'Outcome'
  has_many :dimensions, through: :resource_joins, source: :resourceable, source_type: 'Dimension'

 #  Deprecated - This does not work with reqsequencing/multiple
 #    resources of the same type attached to the same curriculum item
 #   # If Resource matching the params exist, return rec,
 #  # otherwise returns nil
 #  def self.find_resource(resource_code, base_key)
 #    matches = Resource.where(
	#   :resource_code => resource_code,
	#   :base_key => base_key
	# )
	# return matches.first
 #  end

 #  def self.find_or_create(resource_code, base_key)
 #  	resource = self.find_resource(resource_code, base_key)
 #  	return resource || Resource.create(
 #  		:resource_code => resource_code,
 #  		:base_key => base_key
 #  	  )
 #  end

end