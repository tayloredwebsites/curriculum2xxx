class Outcome < BaseRec

  has_one :tree

  # Do not change existing sequence of
  # RESOURCES_TYPES.
  # Only add new resource types to end.
  RESOURCE_TYPES = [
    "proj_ref",
    "learn_prog",
    "class_text",
    "activity",
    "teacher_ref",
    "goal",
  ]

  # Field Translations
  def get_evidence_of_learning_key
    return base_key + ".evid_learning"
  end

  def get_connections_key
    return base_key + ".connections"
  end

  def get_explain_key
    return base_key + ".explain"
  end

  def get_base_key(tree_base_key)
    return tree_base_key + '.outc'
  end

  ######
  # Field Translations: Reference/Resources
  def get_resource_key(resource_type)
    if RESOURCE_TYPES.include?(resource_type)
      return "#{base_key}.#{resource_type}"
    else
      return nil
    end
  end

# TO DO: take out sector_set_code. Not needed anymore.
  def self.get_resource_name(resource_type, tree_type_code, version_code, locale_code)
    resource_index = RESOURCE_TYPES.index(resource_type)
    name = ''
    if resource_index
      name = Translation.find_translation_name(
          locale_code,
          "curriculum.#{tree_type_code}.#{version_code}.ref_type_name.#{resource_type}",
          nil
        ) || I18n.translate("trees.labels.teacher_field_#{resource_index + 1}")
    end
    return name
  end

# TO DO: take out sector_set_code. Not needed anymore.
  def self.get_resource_hash(resource_type, tree_type_code, version_code, locale_code)
    resource_index = RESOURCE_TYPES.index(resource_type)
    name = ''
    if resource_index
      name = Translation.find_translation_name(
          locale_code,
          "curriculum.#{tree_type_code}.#{version_code}.ref_type_name.#{resource_type}",
          nil
        ) || I18n.translate("trees.labels.teacher_field_#{resource_index + 1}")
    end
    return {
      key: "curriculum.#{tree_type_code}.#{version_code}.ref_type_name.#{resource_type}",
      name: name
    }
  end

end
