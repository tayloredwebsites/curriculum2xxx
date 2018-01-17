class Sector < BaseRec

  has_and_belongs_to_many :trees

  def self.sectorCodeFromTranslationCode(sectorCode)
    matches = sectorCode.split('.')
    if matches.length == 3 && matches[0] == 'sector' && matches[2] == 'name'
      return matches[1]
    else
      return ''
    end
  end

  def self.TranslationCodeFromsectorCode(sectorCode)
    if ALL_SECTORS.include?(sectorCode)
      return "sector.#{sectorCode}.name"
    else
      return ''
    end
  end

end
