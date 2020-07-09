class UserResource < BaseRec
  belongs_to :user
  belongs_to :resource
  belongs_to :user_resourceable, polymorphic: true, optional: true
end