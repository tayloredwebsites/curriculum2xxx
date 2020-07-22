class LessonPlan < BaseRec
  has_many :user_lesson_plans
  has_many :activities, :class_name => 'Activity'
  has_many :resource_joins, as: :resourceable
  has_many :resources, through: :resource_joins
  has_many :user_resources, as: :user_resourceable
  belongs_to :user, optional: true
  belongs_to :tree
  has_many :users, through: :user_lesson_plans

  RESOURCE_CODES = [
  	'evid_achievement',
  	'objective',
  	'reflections',
  ]

  def name_key
  	return "lesson_plan.#{id}.name"
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
   text = "#{is_exemplar ? "<i title='Exemplar Lesson Plan' class='fa fa-star'></i> " : ""}<strong>#{I18n.t('lesson_plan.title')}:</strong>"
   return {
      table_partial_name: 'trees/show/simple_header',
      headers_array: [{text: text }],
      content_array: [{transl_key: name_key}]
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

end