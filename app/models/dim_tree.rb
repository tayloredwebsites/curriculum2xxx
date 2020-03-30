class DimTree < BaseRec
  # note cannot use DimensionTree as model class name, it always returned:
  # NameError: uninitialized constant DimensionTree
  self.table_name = 'dimension_trees'
  belongs_to :dimension
  belongs_to :tree

  scope :active, -> { where(:active => true) }

  # To Do: fill this in
  def createOrUpdateDimTree()
  end

  # Standard for dim_explanation_key
  # e.g. TFV.v01.bio.9.1.1.1.miscon.3.expl
  def self.getDimExplanationKey(treeNameKey, dimType, dimId)
    return "#{treeNameKey}.#{dimType}.#{dimId}.expl"
  end



end