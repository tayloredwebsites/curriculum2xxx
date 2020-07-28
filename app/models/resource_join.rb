class ResourceJoin < BaseRec
  belongs_to :resource
  belongs_to :resourceable, polymorphic: true
  belongs_to :user, optional: true

  scope :active, -> { where(:active => true) }
end