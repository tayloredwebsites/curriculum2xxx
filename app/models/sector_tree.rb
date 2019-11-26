class SectorTree < BaseRec
  belongs_to :sector
  belongs_to :tree

  scope :active, -> { where(:active => true) }
end