
class Upload < BaseRec

  # LONG_HEADERS = [ "Area", "Component", "Outcome", "Indicator", "Grade band", "relevant KBE sectors (as determined from KBE spreadsheets)", "Explanation of how the indicator relates to KBE sector", "Closely related learning outcomes applicable to KBE sector", "Mathematics", "Geography", "Physics", "Biology", "ICT" ]
  # SHORT_HEADERS = [ :area, :component, :outcome, :indicator, :gradeBand, :relevantKbe, :sectorRelation, :chemistry, :mathematics, :geography, :physics, :biology, :computers]

  TO_SHORT_HASH = {
    :"en" => {
      :"sheetID" => :row,
      :"Area" => :area,
      :"Component" => :component,
      :"Outcome" => :outcome,
      :"Indicator" => :indicator,
      :"Grade band" => :gradeBand,
      :"relevant KBE sectors (as determined from KBE spreadsheets)" => :relevantKbe,
      :"Explanation of how the indicator relates to KBE sector" => :sectorRelation,
      :"Closely related learning outcomes applicable to KBE sector" => :currentSubject,
      :"Chemistry" => :chemistry,
      :"Mathematics" => :mathematics,
      :"Geography" => :geography,
      :"Physics" => :physics,
      :"Biology" => :biology,
      :"ICT" => :computers
    },
    :"bs" => {
      :"sheetID" => :row,
      :"Oblast" => :area,
      :"Komponenta" => :component,
      :"Ishod" => :outcome,
      :"Pokazatelj" => :indicator,
      :"Raspon" => :gradeBand,
      :"Relevantni KBE sektori:" => :relevantKbe,
      :"Objašnjenje kako se pokazatelji odnose prema KBE sektorima:" => :sectorRelation,
      :"Usko povezani ishodi učenja koji se odnose na KBE sektor:" => :currentSubject,
      :"Kemija" => :chemistry,
      :"Matematika" => :mathematics,
      :"Geografija" => :geography,
      :"Fizika" => :physics,
      :"Biologija" => :biology,
      :"IKT" => :computers
    },
    :"hr" => {
      :"sheetID" => :row,
      :"Area" => :area,
      :"Component" => :component,
      :"Outcome" => :outcome,
      :"Indicator" => :indicator,
      :"Grade band" => :gradeBand,
      :"relevant KBE sectors (as determined from KBE spreadsheets)" => :relevantKbe,
      :"Explanation of how the indicator relates to KBE sector" => :sectorRelation,
      :"Closely related learning outcomes applicable to KBE sector" => :currentSubject,
      :"Chemistry" => :chemistry,
      :"Mathematics" => :mathematics,
      :"Geography" => :geography,
      :"Physics" => :physics,
      :"Biology" => :biology,
      :"ICT" => :computers
    },
    :"sr" =>{
      :"sheetID" => :row,
      :"Area" => :area,
      :"Component" => :component,
      :"Outcome" => :outcome,
      :"Indicator" => :indicator,
      :"Grade band" => :gradeBand,
      :"relevant KBE sectors (as determined from KBE spreadsheets)" => :relevantKbe,
      :"Explanation of how the indicator relates to KBE sector" => :sectorRelation,
      :"Closely related learning outcomes applicable to KBE sector" => :currentSubject,
      :"Chemistry" => :chemistry,
      :"Mathematics" => :mathematics,
      :"Geography" => :geography,
      :"Physics" => :physics,
      :"Biology" => :biology,
      :"ICT" => :computers
    }
  }
  SHORT_REQ = {
    :row => true,
    :area => true,
    :component => true,
    :outcome => true,
    :indicator => true,
    :gradeBand => true
  }

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

  def self.get_short(locale, val)
    # puts "locale: #{locale.inspect}"
    # puts "val: #{val.inspect}"
    locale_vals =  Upload::TO_SHORT_HASH[locale.to_sym]
    # puts "locale_vals: #{locale_vals.inspect}"
    # puts "locale_vals: #{locale_vals[val.to_sym]}"
    ret =  locale_vals[val.to_sym]
  end

  # def self.reverse_hash
  #   return Hash[LONG_TO_SHORT_HASH.to_a.reverse]
  # end

  # def self.get_long(locale, val)
  #   to_long = self.reverse_hash(TO_SHORT_HASH[locale])
  #   return to_long[val]
  # end

end

