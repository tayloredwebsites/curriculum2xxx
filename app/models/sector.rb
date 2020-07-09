class Sector < BaseRec

  has_many :sector_trees
  has_many :trees, through: :sector_trees

  # TO DO: investigate migrating key phrases for
  # uploads to tags
  KEY_PHRASES = [
    "population growth",
    "alternative energies",
    "urban congestion",
    "scientific and technological environment",
    "public health",
    "arid areas",
    "clean water",
    "industrial",
    "reduce pollution",
    "recycle",
    "climate change",
    "industry 4.0",
    "sensors and imaging",
    "food tech",
    "biomedical tech",
    "nanotechnology",
    "global warming",
    "internet",
    "population"
  ]

# Translation Field
  def get_name_key
    return "sector.#{sector_set_code}.#{code}.name"
  end

#####################################
#Not Used, & no longer accurate- Should be deprecated?
  def self.sectorCodeFromTranslationCode(sectorCode)
    matches = sectorCode.split('.')
    if matches.length == 3 && matches[0] == 'sector' && matches[2] == 'name'
      return matches[1]
    else
      return ''
    end
  end
  #Not Used, & no longer accurate- Should be deprecated?
  def self.TranslationCodeFromsectorCode(sectorCode)
    if ALL_SECTORS.include?(sectorCode)
      return "sector.#{sectorCode}.name"
    else
      return ''
    end
  end

end
