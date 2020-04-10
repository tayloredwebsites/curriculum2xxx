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

end
