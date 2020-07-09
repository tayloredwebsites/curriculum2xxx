class ResourceJoin < BaseRec
  belongs_to :resource
  belongs_to :resourceable, polymorphic: true
end