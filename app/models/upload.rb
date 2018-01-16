class Upload < BaseRec

  LONG_HEADERS = [ "Area", "Component", "Outcome", "Indicator", "Grade band", "relevant KBE sectors (as determined from KBE spreadsheets)", "Explanation of how the indicator relates to KBE sector", "Closely related learning outcomes applicable to KBE sector", "Mathematics", "Geography", "Physics", "Biology", "ICT" ]
  SHORT_HEADERS = [ :area, :component, :outcome, :indicator, :gradeBand, :relevantKbe, :sectorRelation, :chemistry, :mathematics, :geography, :physics, :biology, :computers]

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

  def self.get_long_to_short
    # these are the OCT headers we need (rest are for teacher uploads) in the spreadsheet
    # to do - get translated versions based upon language of upload
    # OCT headers as symbols
    # to do - confirm that eighth header is chemistry - same subject as file ????
    # to do - may need different set of arrays, or mappings for other subjects.
    return Hash[LONG_HEADERS.zip(SHORT_HEADERS)]
  end

  def self.get_short_to_long
    # these are the OCT headers we need (rest are for teacher uploads) in the spreadsheet
    # to do - get translated versions based upon language of upload
    # OCT headers as symbols
    # to do - confirm that eighth header is chemistry - same subject as file ????
    # to do - may need different set of arrays, or mappings for other subjects.
    return Hash[SHORT_HEADERS.zip(LONG_HEADERS)]
  end

end
