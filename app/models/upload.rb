class Upload < BaseRec

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
    long_headers = [ "Area", "Component ", "Outcome", "Indicator", "Grade band", "relevant KBE sectors (as determined from KBE spreadsheets)", "Explanation of how the indicator relates to KBE sector", "Closely related learning outcomes applicable to KBE sector", "Mathematics", "Geography", "Physics", "Biology", "ICT" ]
    # OCT headers as symbols
    # to do - confirm that eighth header is chemistry - same subject as file ????
    # to do - may need different set of arrays, or mappings for other subjects.
    short_headers = [ :area, :component, :outcome, :indicator, :gradeBand, :relevantKbe, :kbeRelation, :chemistry, :mathematics, :geography, :physics, :biology, :computers]
    return Hash[long_headers.zip(short_headers)]
  end

  def self.get_short_to_long
    # these are the OCT headers we need (rest are for teacher uploads) in the spreadsheet
    # to do - get translated versions based upon language of upload
    long_headers = [ "Area", "Component ", "Outcome", "Indicator", "Grade band", "relevant KBE sectors (as determined from KBE spreadsheets)", "Explanation of how the indicator relates to KBE sector", "Closely related learning outcomes applicable to KBE sector", "Mathematics", "Geography", "Physics", "Biology", "ICT" ]
    # OCT headers as symbols
    # to do - confirm that eighth header is chemistry - same subject as file ????
    # to do - may need different set of arrays, or mappings for other subjects.
    short_headers = [ :area, :component, :outcome, :indicator, :gradeBand, :relevantKbe, :kbeRelation, :chemistry, :mathematics, :geography, :physics, :biology, :computers]
    return Hash[short_headers.zip(long_headers)]
  end

end
