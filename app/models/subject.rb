class Subject < BaseRec

  has_and_belongs_to_many :trees

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
