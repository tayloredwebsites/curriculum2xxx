class Upload < ApplicationRecord

  belongs_to :subject
  belongs_to :grade_band
  belongs_to :locale

  validates :subject, presence: true
  validates :grade_band, presence: true
  validates :locale, presence: true

  validates :status, presence: true, allow_blank: false

  scope :upload_listing, -> {
    order('subjects.code', 'grade_bands.code', 'locales.name')
    # where(active: true)
  }

  UPLOAD_STATUS = ['Not Uploaded', 'Tree Uploaded', 'Upload Done']
  UPLOAD_STATUS_NOT_UPLOADED = 0
  UPLOAD_STATUS_TREE_UPLOADED = 1
  UPLOAD_STATUS_UPLOAD_DONE = 2

end
