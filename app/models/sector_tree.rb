class SectorTree < BaseRec
  belongs_to :sector
  belongs_to :tree

  scope :active, -> { where(:active => true) }

  def self.explanationKey(tree_type_code, version_code, tree_code, sector_id)
    "#{tree_type_code}.#{version_code}.#{tree_code}.sector.#{sector_id}"
  end

  def explanationKey(tree_type_code, version_code, tree_code, sector_id)
    "#{tree_type_code}.#{version_code}.#{tree_code}.sector.#{sector_id}"
  end

end