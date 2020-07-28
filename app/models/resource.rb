class Resource < BaseRec
  has_many :resource_joins
  belongs_to :resourceable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  has_many :users, through: :resource_joins

  has_many :trees, through: :resource_joins, source: :resourceable, source_type: 'Tree'
  has_many :outcomes, through: :resource_joins, source: :resourceable, source_type: 'Outcome'
  has_many :dimensions, through: :resource_joins, source: :resourceable, source_type: 'Dimension'
  has_many :lesson_plans, through: :resource_joins, source: :resourceable, source_type: 'LessonPlan'
  has_many :activities, through: :resource_joins, source: :resourceable, source_type: 'Activity'

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
 #

  def name_key
    return "resource.#{id}.name"
  end

  # return translation key for name of resource type for the
  # given resourceCode. E.g., "Comments", "Goal Behavior", etc
  def self.get_type_key(treeTypeCode, versionCode, resourceCode)
    return "#{treeTypeCode}.#{versionCode}.resources.#{resourceCode}"
  end

  def self.build_generic_column(treeType, version, resource_code, resourceable, joins, resources, user_for_joins)
    urls = Rails.application.routes.url_helpers
    popup_options = {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'}
    translKeys = [Resource.get_type_key(treeType.code, version.code, resource_code)]
    header = {transl_key: Resource.get_type_key(treeType.code, version.code, resource_code)}
    content = []
    joinsByResourceId = Hash[joins.map { |j| [j.resource_id, j] }]
    resources.each do |r|
      content << {
          rec: joinsByResourceId[r.id],
          transl_key: r.name_key,
          # delete: { path: "#" },
          edit: { path: urls.edit_resource_path(id: r.id), options: popup_options }
      }
      translKeys << r.name_key
    end #sourceData[:resourcesByCode][resource_code].each do |r|
    # No resources with this resource_code
    # currently attached to the Tree at tree_depth
    if (content.length == 0)
      user_id = user_for_joins ? user_for_joins.id : nil
      content << {
        # TODO: add user_id to ResourceJoin once column is added to that table
        rec: ResourceJoin.new(resourceable: resourceable, user_id: user_id),
        transl_key: nil,
        edit: { path: urls.new_resource_path(
            resource: { resource_code: resource_code, resourceable_id: resourceable.id, resourceable_type: resourceable.class.to_s, user_id: user_id },
          ),
        options: popup_options }
      }
    end
    return [
      header,
      content,
      translKeys
    ]
  end

  def self.build_generic_table(treeType, version, resource_codes, resourceable, joins, resourcesByCode, user_for_joins)
    table = Hash.new { |h, k| h[k] = [] }
    translKeys = []
    depths = { 'LessonPlan': 0, 'Activity': 2 }
    table[:table_partial_name] = 'trees/show/generic_table'
    table[:expandable], table[:depth] = [false, depths[:"#{resourceable.class.to_s}"]]
    resource_codes.each do |code|
      header, content, keys = build_generic_column(treeType, version, code, resourceable, joins, resourcesByCode[code], user_for_joins)
      table[:headers_array] << header
      table[:content_array] << content
      translKeys.concat(keys)
    end
    return [table, translKeys]
  end

  def clone_with_translations
    #dup creates a shallow copy with a nil id
    r = dup
    ActiveRecord::Base.transaction do
      r.save
      Translation.copy_translations_for_key(name_key, r.name_key)
    end
    return r
  end

end