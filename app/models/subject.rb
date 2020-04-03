class Subject < BaseRec

  has_and_belongs_to_many :trees

  # Translation Field

  # The TreeType-specific Translation key for a Subject
  def versioned_name_key
    treeTypeRec = TreeType.find(tree_type_id)
    return "subject.#{treeTypeRec.code}.#{code}.name"
  end

  # The TreeType-specific Translation key for a Subject
  def versioned_abbr_key
    treeTypeRec = TreeType.find(tree_type_id)
    return "subject.#{treeTypeRec.code}.#{code}.abbr"
  end

  # The default Translation key for BaseRec subjects
  # To Do: migrate to use subject.default.#{code}.name
  def self.name_translation_key(code)
    return "subject.base.#{code}.name"
  end

  # The default Translation key for BaseRec subjects
  # To Do: migrate to use subject.default.#{code}.name
  def self.default_abbr_key(code)
    return "subject.base.#{code}.abbr"
  end

  def get_name(locale_code)
    return Translation.find_translation_name(
        locale_code,
        versioned_name_key,
        nil
      ) || Translation.find_translation_name(
        locale_code,
        Subject.name_translation_key(code),
        ""
      )
  end

  def get_abbr(locale_code)
    return Translation.find_translation_name(
        locale_code,
        versioned_abbr_key,
        nil
      ) || Translation.find_translation_name(
        locale_code,
        Subject.default_abbr_key(code),
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
