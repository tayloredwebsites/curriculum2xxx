class ResourceJoin < BaseRec
  belongs_to :resource
  belongs_to :resourceable, polymorphic: true

  scope :active, -> { where(:active => true) }
end