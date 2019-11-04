class TreeTree < BaseRec
  belongs_to :tree_referencer, class_name: 'Tree'
  belongs_to :tree_referencee, class_name: 'Tree'

  AKIN_KEY = 'akin'
  APPLIES_KEY = 'applies'
  DEPENDS_KEY = 'depends'

  def reciprocal_relationship(relation)
  	lookup = {
      :akin => 'akin',
      :applies => 'depends',
      :depends => 'applies'
    }
    lookup[relation]
  end
end