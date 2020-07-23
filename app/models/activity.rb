class Activity < BaseRec
  belongs_to :lesson_plan
  has_many :activity_dimensions
  has_many :dimensions, through: :activity_dimensions
  belongs_to :dimension, optional: true
  has_many :resource_joins, as: :resourceable
  has_many :resources, through: :resource_joins
  has_many :user_resources, as: :user_resourceable

  # Used by the curriculum seed processes
  # to create translations for these
  # items.
  RESOURCE_CODES = [
    'purpose',
    'student_org', #lookup table
    'teach_strat', #lookup table
    'connections',
    'formative_assessment',
    'desc_activity',
  ]

  def name_key
    return "activities.#{id}.name"
  end

  def desc_key
    "activities.#{id}.desc"
  end

  def build_header_table(header_type, resourcesByCode, selectOptionsById, joins, treeType, version)
    urls = Rails.application.routes.url_helpers
    popup_options = {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'}
    activity_title = "#{I18n.translate('lesson_plan.segment_with_num', sequence: sequence)} - #{I18n.t('app.labels.title')}"
    header_types = {
      title: {
        text: "<strong>#{I18n.t('app.labels.title')}:</strong>",
        key: name_key,
        edit: { path: urls.edit_translation_path(id: 'nil', translation: {key: name_key, title: activity_title, disable_ckeditor: true } ), options: popup_options },
      },
      time_min: {
        text: I18n.t('activity.time_min', min: self.time_min.to_i),
      },
      student_org: {
        header_key: Resource.get_type_key(treeType.code, version.code, 'student_org'),
        key: selectOptionsById[student_org.to_i],
      },
      teach_strat: {
        header_key: Resource.get_type_key(treeType.code, version.code, 'teach_strat'),
        key: selectOptionsById[teach_strat.to_i],
      },
      # desc: {
      #   text:  "<strong>#{I18n.t('activity.desc')}:</strong>",
      #   key: desc_key,
      #   edit: { path: urls.edit_translation_path(id: 'nil', translation: {key: desc_key, title: I18n.t('activity.desc')} ), options: popup_options },
      # },
    }
    translKeys = [header_types[header_type][:key]]
    translKeys << header_types[header_type][:header_key] if header_types[header_type][:header_key]
    return [
      {
        table_partial_name: 'trees/show/simple_header',
        headers_array: [{text: header_types[header_type][:text], transl_key: header_types[header_type][:header_key] }],
        content_array: [
          {
            transl_key: header_types[header_type][:key],
            edit: header_types[header_type][:edit],
          }
        ]
      },
      translKeys
    ]
  end


  # def self.options_hash_and_transl_keys
  # 	optionsHash = Hash.new { |h, k| h[k] = [] }
  # 	translKeys = []
  # 	LookupTablesOption.where(
  # 		table_name: LOOKUP_TABLES
  # 	).each do |l|
  #     translKeys << l.lookup_translation_key
  # 	  optionsHash[l.table_name] << l
  # 	end
  # 	return [optionsHash, translKeys]
  # end


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
  def build_activity_tables(treeType, version, lp, user_for_joins)
    #(treeType, version, resource_codes, resourceable, joins, resourcesByCode, user_for_joins)
    activity = { sequence: sequence, name_key: name_key, tables: [] }
    resourcesByCode = Hash.new { |h, k| h[k] = [] }
    dimensionsByCode = Hash.new { |h, k| h[k] = [] }
    selectOptionsById = Hash[
        LookupTablesOption.where(
            id: [teach_strat, student_org]
        ).map { |opt| [opt.id, opt.name_key] }
      ]
    translKeys = []

    if user_for_joins
      joins = user_resources
      Resource.where(id: user_resources.pluck('resource_id').uniq).each { |r| resourcesByCode[r.resource_code] << r }
    else
      resources.each { |r| resourcesByCode[r.resource_code] << r }
      joins = resource_joins
    end

    dimensions.each { |d| dimensionsByCode[d.dim_code] = d }

    #activity headers
    [:title, :time_min, :student_org, :teach_strat].each do |header_type|
      table, keys = build_header_table(header_type, resourcesByCode, selectOptionsById, joins, treeType, version)
      activity[:tables] << table
      translKeys.concat(keys)
    end

    #activity resources
    # resource_codes.each do |code|
    #   header, content, keys = build_generic_column(treeType, version, code, resourceable, joins, resourcesByCode[code], user_for_joins)
    #   table[:headers_array] << header
    #   table[:content_array] << content
    #   translKeys.concat(keys)
    # end
    ['desc_activity', 'connections', 'formative_assessment'].each do |r_code|
      table, keys = Resource.build_generic_table(
        treeType,
        version,
        [r_code],
        self,
        joins,
        resourcesByCode,
        user_for_joins
      )
      activity[:tables] << table
      translKeys.concat(keys)
    end

    #activity dimensions
    table, keys = ActivityDimension.build_generic_table(
        treeType,
        version,
        ['concept', 'skill'],
        self,
        activity_dimensions,
        dimensionsByCode
      )
      activity[:tables] << table if table
      translKeys.concat(keys) if keys


    return [activity, translKeys]
  end

end