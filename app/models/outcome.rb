class Outcome < BaseRec

  has_one :tree

  REF_TYPES = [
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
  def get_ref_key(ref_type)
    if REF_TYPES.include?(ref_type)
      return "#{base_key}.#{ref_type}"
    else
      return nil
    end
  end

  def self.get_ref_name(ref_type, locale_code, sector_set_code)
    ref_index = REF_TYPES.index(ref_type)
    name = ''
    if ref_index
      name = Translation.find_translation_name(
          locale_code,
          "ref_type_name.#{ref_type}",
          nil
        ) || I18n.translate("trees.labels.teacher_field_#{ref_index + 1}", sector_set: sector_set_code)
    end
    return name
  end

  def self.get_ref_hash(ref_type, locale_code, sector_set_code)
    ref_index = REF_TYPES.index(ref_type)
    name = ''
    if ref_index
      name = Translation.find_translation_name(
          locale_code,
          "ref_type_name.#{ref_type}",
          nil
        ) || I18n.translate("trees.labels.teacher_field_#{ref_index + 1}", sector_set: sector_set_code)
    end
    return {key: "ref_type_name.#{ref_type}", name: name}
  end

end
