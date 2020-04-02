class SectorTree < BaseRec
  belongs_to :sector
  belongs_to :tree

  scope :active, -> { where(:active => true) }

  # Translation Field
  def self.explanationKey(tree_type_code, version_code, tree_id, sector_id)
    "#{tree_type_code}.#{version_code}.tree.#{tree_id}.sector.#{sector_id}"
  end

  def explanationKey(tree_type_code, version_code, tree_id, sector_id)
    "#{tree_type_code}.#{version_code}.tree.#{tree_id}.sector.#{sector_id}"
  end
  #########################################
end