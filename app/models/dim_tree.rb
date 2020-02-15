class DimTree < BaseRec
  # note cannot use DimensionTree as model class name, it always returned:
  # NameError: uninitialized constant DimensionTree
  self.table_name = 'dimension_trees'
  belongs_to :dimension
  belongs_to :tree

  scope :active, -> { where(:active => true) }
end