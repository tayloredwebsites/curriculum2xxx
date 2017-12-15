class Upload < ApplicationRecord

  belongs_to :subject
  belongs_to :grade_band
  belongs_to :locale

  validates :subject, presence: true
  validates :grade_band, presence: true
  validates :locale, presence: true

  scope :upload_listing, -> {
    order('subjects.code', 'grade_bands.code', 'locales.name')
    # where(active: true)
  }

  UPLOAD_STATUS = ['Not Uploaded', 'Validated', 'Tree Uploaded', 'Indicators Uploaded', 'KBE Sectors related', 'Indicators related', 'Upload Done']

end
