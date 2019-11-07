class TreeTree < BaseRec
  belongs_to :tree_referencer, class_name: 'Tree'
  belongs_to :tree_referencee, class_name: 'Tree'

  AKIN_KEY = 'akin'
  APPLIES_KEY = 'applies'
  DEPENDS_KEY = 'depends'

  scope :active, -> { where(:active => true) }

  def self.reciprocal_relationship(relation)
  	lookup = {
      :"#{AKIN_KEY}" => AKIN_KEY,
      :"#{APPLIES_KEY}" => DEPENDS_KEY,
      :"#{DEPENDS_KEY}" => APPLIES_KEY
    }
    lookup[relation] || lookup[:"#{relation}"]
  end
end