class Outcome < BaseRec

  has_one :tree

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

end
