class Subject < BaseRec

  has_and_belongs_to_many :trees

  # Translation Field

  def build_base_key
    treeTypeRec = TreeType.find(tree_type_id)
    versionRec = Version.find(treeTypeRec.version_id)
    return "subject.#{treeTypeRec.code}.#{versionRec.code}.#{code}"
  end

  # Returns curriculum-specific translation key for a subject name.
  def get_versioned_name_key
    return "#{build_base_key}.name"
  end

  # Returns curriculum-specific translation key for a subject abbreviation.
  def get_versioned_abbr_key
    return "#{build_base_key}.abbr"
  end

  # The default Translation key for BaseRec subject names
  def self.get_default_name_key(code)
    return "subject.default.#{code}.name"
  end

  # The default Translation key for BaseRec subject abbreviations
  def self.get_default_abbr_key(code)
    return "subject.default.#{code}.abbr"
  end

  def get_name(locale_code)
    return Translation.find_translation_name(
        locale_code,
        get_versioned_name_key,
        nil
      ) || Translation.find_translation_name(
        locale_code,
        Subject.get_default_name_key(code),
        ""
      )
  end

  def get_abbr(locale_code)
    return Translation.find_translation_name(
        locale_code,
        get_versioned_abbr_key,
        nil
      ) || Translation.find_translation_name(
        locale_code,
        Subject.get_default_abbr_key(code),
        ""
      )
  end
  ########################################

  def abbr(loc)
    Rails.logger.debug("loc: #{loc.inspect}")
    Rails.logger.debug("self.base_key: #{self.base_key.inspect}")
    recs = Translation.where(locale: loc, key: self.base_key+'.abbr')
    Rails.logger.debug("abbr recs count: #{recs.count}")
    recs.each do |r|
      Rails.logger.debug("abbr rec: #{r.inspect}")
    end
    if recs.count > 0
      return recs.first.value
    else
      return ''
    end
  end

  def name(loc)
    Translation.where(locale: loc, key: self.base_key+'.name').first.value
  end

  def getSubjectGradeBands()
    gbIDs = Tree.where(:subject_id => self.id).pluck('grade_band_id').uniq
    gbRecs = GradeBand.where(:id => gbIDs).order('max_grade asc')
    gbRecs
  end

end
