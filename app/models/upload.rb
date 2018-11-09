
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
      :"Relevantni sektori KBE" => :relevantKbe,
      :"Objašnjenje kako se indikator odnosi na KBE sektor" => :sectorRelation,
      :"Usko povezani ishodi učenja koji se odnose na KBE sektor:" => :currentSubject,
      :"Tijesno povezani ishodi uÄenja koji se odnose na KBE sektor:" => :currentSubject,
      :"Tijesno povezani ishodi učenja koji se odnose na KBE sektor:" => :currentSubject,
      :"Kemija" => :chemistry,
      :"Hemija" => :chemistry,
      :"Matematika" => :mathematics,
      :"Geografija" => :geography,
      :"Moja okolina, Priroda i društvo" => :geography,
      :"Fizika" => :physics,
      :"Biologija" => :biology,
      :"IKT" => :computers,
      :"Informatika" => :computers
    },
    :"hr" => {
      :"sheetID" => :row,
      :"Oblast" => :area,
      :"Komponenta" => :component,
      :"Ishod" => :outcome,
      :"Pokazatelj" => :indicator,
      :"Raspon" => :gradeBand,
      :"Relevantni KBE sektori:" => :relevantKbe,
      :"Relevantni sektori KBE" => :relevantKbe,
      :"Objašnjenje kako se pokazatelji odnose prema KBE sektorima:" => :sectorRelation,
      :"Objašnjenje kako se indikator odnosi na KBE sektor" => :sectorRelation,
      :"Usko povezani ishodi učenja koji se odnose na KBE sektore:" => :currentSubject,
      :"Tijesno povezani ishodi učenja koji se odnose na KBE sektor" => :currentSubject,
      :"Kemija" => :chemistry,
      :"Matematika" => :mathematics,
      :"Geografija" => :geography,
      :"Fizika" => :physics,
      :"Biologija" => :biology,
      :"IKT" => :computers
    },
    :"sr" =>{
      :"sheetID" => :row,
      :"Oblast" => :area,
      :"Komponenta" => :component,
      :"Ishod" => :outcome,
      :"Pokazatelj" => :indicator,
      :"Raspon" => :gradeBand,
      :"Релевантни сектори економије засноване на знању (ЕЗЗ)" => :relevantKbe,
      :"Рeлeвaнтни сектори економије засноване на знању (ЕЗЗ)" => :relevantKbe,
      :"Објашњење како се индикатор односи на секторе ЕЗЗ-а" => :sectorRelation,
      :"Тијесно повезани исходи учења који се односе на секторе ЕЗЗ-а" => :currentSubject,
      :"Хемија" => :chemistry,
      :"Математика" => :mathematics,
      :"Географија" => :geography,
      :"Физика" => :physics,
      :"Биологија" => :biology,
      :"ИКТ" => :computers
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

  TO_SUBJECT_CODE = {
    :currentSubject => '',
    :chemistry => 'Hem',
    :mathematics => 'Mat',
    :geography => 'Geo',
    :physics => 'Fiz',
    :biology => 'Bio',
    :computers => 'IT'
  }

  TO_SUBJECT_ID = {
    :currentSubject => 0,
    :chemistry => 4,
    :mathematics => 6,
    :geography => 3,
    :physics => 2,
    :biology => 1,
    :computers => 5
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
    ret = val.present? ? locale_vals[val.strip.to_sym] : ''
  end

  # def self.reverse_hash
  #   return Hash[LONG_TO_SHORT_HASH.to_a.reverse]
  # end

  # def self.get_long(locale, val)
  #   to_long = self.reverse_hash(TO_SHORT_HASH[locale])
  #   return to_long[val]
  # end

end

