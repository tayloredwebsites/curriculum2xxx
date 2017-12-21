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

  # to do - get these from translation table
  UPLOAD_STATUS = ['Not Uploaded', 'Tree Upload Started', 'Tree Uploaded', 'Related to KBE', 'Subjects Relations Started', 'Upload Done']
  UPLOAD_PROGRESS_PCT = [0, 25, 50, 75, 100]
  UPLOAD_STATUS_NOT_UPLOADED = 0
  UPLOAD_STATUS_TREE_UPLOADED = 1
  UPLOAD_STATUS_KBE_RELATED = 2
  UPLOAD_STATUS_SUBJ_RELATED = 3
  UPLOAD_STATUS_DONE = 4

end
