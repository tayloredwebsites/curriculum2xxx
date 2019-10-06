class TreeTree < BaseRec
  belongs_to :tree_referencer, class_name: 'Tree'
  belongs_to :tree_referencee, class_name: 'Tree'
end