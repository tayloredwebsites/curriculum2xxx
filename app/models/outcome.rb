class Outcome < BaseRec

  has_one :tree
  has_many :resource_joins, as: :resourceable
  has_many :user_resources, as: :user_resourceable
  has_many :resources, through: :resource_joins

  # Do not change existing sequence of
  # RESOURCES_TYPES.
  # Only add new resource types to end.
  #
  # See special processing behavior for specific
  # resource types in BaseRec.process_resource_content(type, content)
  RESOURCE_TYPES = [
    "proj_ref",  #0
    "learn_prog", #1- lesson plans
    "class_text", #2
    "activity", #3
    "teacher_ref", #4
    "goal", #5
    "explain", #6- teacher support/explanatory comments
    "evid_learning", #7
    "connections", #8 - capstone connections
    "sec_topic", #9
    "sec_code", #10
    "cog_demand", #11 - SEC Cognitive Demand
    "lp_ss_id", #12- TO DO: change to lp_google_ss_id: Lesson Plan (expect a Google Spreadsheet Id)
    "review_comments" #13 - WL Review Comments
  ]

  # Field Translations

  # deprecated
  def get_evidence_of_learning_key
    return base_key + ".evid_learning"
  end

  # deprecated
  def get_connections_key
    return base_key + ".connections"
  end

  #deprecated
  def get_explain_key
    return base_key + ".explain"
  end

  def get_base_key(tree_base_key)
    return tree_base_key + '.outc'
  end

  def self.build_base_key(tree_base_key)
    return tree_base_key + '.outc'
  end

  ######
  # Field Translations: Outcome Resources
  def get_resource_key(resource_type)
    if RESOURCE_TYPES.include?(resource_type)
      return "#{base_key}.#{resource_type}"
    else
      return nil
    end
  end

  # To Do: deprecate the Translation Table for Resource Names (ensure seed file provides these)
  # To Do: provide a default value in call to find_translation_name indicating missing resource name in Seed file
  def self.get_resource_name(resource_type, tree_type_code, version_code, locale_code)
    resource_index = RESOURCE_TYPES.index(resource_type)
    name = ''
    if resource_index
      name = Translation.find_translation_name(
          locale_code,
          "curriculum.#{tree_type_code}.#{version_code}.resource_type_name.#{resource_type}",
          nil
        ) || I18n.translate("trees.labels.teacher_field_#{resource_index + 1}")
    end
    return name
  end

  def self.get_resource_key(resource_type, tree_type_code, version_code)
    return "curriculum.#{tree_type_code}.#{version_code}.resource_type_name.#{resource_type}"
  end

  # To Do: deprecate the Translation Table for Resource Names (ensure seed file provides these)
  # To Do: provide a default value in call to find_translation_name indicating missing resource name in Seed file
  def self.get_resource_hash(resource_type, tree_type_code, version_code, locale_code)
    resource_index = RESOURCE_TYPES.index(resource_type)
    name = ''
    if resource_index
      name = Translation.find_translation_name(
          locale_code,
          "curriculum.#{tree_type_code}.#{version_code}.resource_type_name.#{resource_type}",
          nil
        ) || I18n.translate("trees.labels.teacher_field_#{resource_index + 1}")
    end
    return {
      key: "curriculum.#{tree_type_code}.#{version_code}.resource_type_name.#{resource_type}",
      name: name
    }
  end

  def list_translation_keys
    RESOURCE_TYPES.map { |type| get_resource_key(type) }
  end

  def list_instance_translation_keys(outc_base_key)
    RESOURCE_TYPES.map { |type| "#{outc_base_key}.#{type}" }
  end

end
