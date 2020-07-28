class LessonPlan < BaseRec
  has_many :user_lesson_plans
  has_many :activities, :class_name => 'Activity'
  has_many :resource_joins, as: :resourceable
  has_many :resources, through: :resource_joins
  belongs_to :user, optional: true
  belongs_to :tree
  has_many :users, through: :user_lesson_plans

  RESOURCE_CODES = [
  	'evid_achievement',
  	'objective',
  	'reflections',
  	'lesson_start',
  	'lesson_closure',
  ]

  scope :active, -> { where(:active => true) }
  scope :working, -> { active.where(:is_exemplar => false) }
  scope :exemplar, -> { active.where(:is_exemplar => true) }

  def name_key
  	return "lesson_plan.#{id}.name"
  end

  def self.lp_table_header_key(working)
  	return "lesson_plan.title.#{working ? 'working' : 'exemplar'}"
  end

  # used by cancancan to determine if the user should have
  # :edit access to a working lesson plan
  def authored_by?(user)
  	self.users.pluck('id').include?(user.id)
  end

  # {
  #   rec: rec,
  #   label_key: nil,
  #   transl_key: str,
  #   detail_href: nil || path
  #   edit: nil || { path, options: {} },
  #   delete: nil || { path, options: {} },
  # },
  def self.build_listing_table(tree, user_for_joins)
  	urls = Rails.application.routes.url_helpers
  	translKeys = []
  	header = {transl_key: lp_table_header_key(user_for_joins.present?)}
  	header[:add] = {
  		path: urls.new_lesson_plan_path(lesson_plan: {tree_id: tree.id}, user_lesson_plan: {user_id: user_for_joins.id}),
  		options: {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'},
  	} if user_for_joins.present?
  	content = []
  	translKeys << header[:transl_key]
  	if user_for_joins
  	# Looking up working LPs for the current user
  	  lps = []
  	  lpsForTree = where(tree: tree).order('sequence')
  	  lpIds = lpsForTree.pluck('id')
  	  joins = UserLessonPlan.where(user: user_for_joins, lesson_plan_id: lpIds).group_by(&:lesson_plan_id)
  	  lpsForTree.each { |lp| lps << lp if joins[lp.id] }
  	else
  	# Looking up exemplar LPs for the given tree
  	  lps = where(tree: tree, is_exemplar: true).order('sequence')
  	end

  	lps.each do |lp|
  		content << {
  			rec: lp,
  			transl_key: lp.name_key,
  			detail_href: urls.lesson_plan_path(id: lp.id)
  		}
  		translKeys << lp.name_key
  	end

  	if content.length == 0
  		content << {
  			rec: LessonPlan.new,
  			transl_key: 'nil',
  		}
  	end

  	return [header, content, translKeys]
  end

  # def build_show_page_data
  # 	tablesHash = {}
  # 	tablesHash[:headers] = []

  # 	translKeys = [name_key]
  #   users
  #   @activities = @lesson_plan.activities.order('sequence')
  #   @resourcesByCode = Hash.new { |h, k| h[k] = [] }
  #   @lesson_plan.resources.each do |r|
  #     @resourcesByCode[r.resource_code] << r
  #     translKeys << r.name_key
  #   end
  #   return [tablesHash, translKeys]
  # end #def build_show_page_data

  def build_header_table
   text = "<strong>#{I18n.t('app.labels.title')}:</strong>"
   edit_text = "#{I18n.t('lesson_plan.title')} - #{I18n.t('app.labels.title')}"
   urls = Rails.application.routes.url_helpers
   popup_options = {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'}
   return {
      table_partial_name: 'trees/show/simple_header',
      headers_array: [{text: text }],
      content_array: [{
      	rec: self,
      	transl_key: name_key,
      	edit: {path: urls.edit_translation_path(id: 'nil', translation: {key: name_key, title: edit_text } ), options: popup_options }
      }]
    }
  end


  # returns:
  # {
  #   table_partial_name: 'activities/show',
  #   activities: [
  #     {
  #       sequence: 1, # integer- sequence of activity in LP
  #       tables: [
  #         {
  #           table_partial_name: '...',
  #           headers_array: [...],
  #           content_array: [...],
  #         },
  #         {...},
  #         ...
  #       ]
  #     },
  #     {...},
  #     ...
  #   ]
  # }
  #
  # AND
  #
  # translKeys array
  def build_activities_tables(treeType, version, user_for_joins)
  	translKeys = []
  	table = {table_partial_name: 'activities/show', activities: []}
  	activities.order('sequence').each do |activity|
  		t, keys = activity.build_activity_tables(
  			treeType,
  			version,
  			self,
  			user_for_joins
  		)
  		table[:activities] << t
  		translKeys.concat(keys)
  	end

  	return [table, translKeys]
  end


  def clone_and_join_activity(old_activity, user_for_joins)
  	ActiveRecord::Base.transaction do
  		activity_clone = old_activity.dup
  		activity_clone.lesson_plan_id = self.id
  		activity_clone.save
  		Translation.copy_translations_for_key(old_activity.name_key, activity_clone.name_key)
	    resource_ids = old_activity.resource_joins.pluck('resource_id').uniq
	    activity_clone.clone_and_join_resources(Resource.where(id: resource_ids), user_for_joins)
	    activity_clone.bulk_join_dimensions(old_activity.dimensions)
  	end
  end

end
