class TreeTree < BaseRec
  belongs_to :tree_referencer, class_name: 'Tree'
  belongs_to :tree_referencee, class_name: 'Tree'

  AKIN_KEY = 'akin'
  APPLIES_KEY = 'applies'
  DEPENDS_KEY = 'depends'
  recip_lookup = Hash.new 
  recip_lookup[AKIN_KEY] = AKIN_KEY
  recip_lookup[APPLIES_KEY] = DEPENDS_KEY
  recip_lookup[DEPENDS_KEY] = APPLIES_KEY

  def reciprocal_relationship(relation)
  	lookup = {
      :akin => 'akin',
      :applies => 'depends',
      :depends => 'applies'
    }
    lookup[relation]
  end
end