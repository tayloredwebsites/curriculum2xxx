class Tree < BaseRec


  belongs_to :tree_type
  belongs_to :version
  belongs_to :subject
  belongs_to :grade_band

  has_and_belongs_to_many :sectors

  # does not seem to be working ?
  # has_many :my_translations

  # are these necessary?
  validates :tree_type, presence: true
  validates :version, presence: true
  validates :subject, presence: true
  validates :grade_band, presence: true

  validates :code, presence: true, allow_blank: false

  # removed for testing issues.  set values in controller
  # # scope for hard coded variables
  # scope :otc_tree, -> {
  #   where(tree_type_id: TREE_TYPE_ID, version_id: VERSION_ID)
  # }
  scope :otc_listing, -> {
    order('subjects.code', 'grade_bands.code', 'locales.name')
    # where(active: true)
  }

  def codeArray
    if self.code.present?
      return self.code.split('.')
    else
      return nil
    end
  end

  # return the depth of the code (return 3 from a.b.c)
  def depth
    if self.code.present?
      return self.codeArray.count
    else
      return nil
    end
  end

  # return the last code in the code string (return c from a.b.c)
  def subCode
    if self.code.present?
      return self.codeArray[-1]
    else
      return nil
    end
  end

  def parentCode
    arr = self.codeArray
    if arr && arr.length > 0
      arr.pop(1)
      return arr.join('.')
    else
      return ''
    end
  end

  def area
    if self.depth.present? && self.depth > 0
      return self.codeArray[0]
    else
      return nil
    end
  end

  def component
    if self.depth.present? && self.depth > 1
      return self.codeArray[1]
    else
      return nil
    end
  end

  def outcome
    if self.depth.present? && self.depth > 2
      return self.codeArray[2]
    else
      return nil
    end
  end

  def indicator
    if self.depth.present? && self.depth > 3
      return self.codeArray[3]
    else
      return nil
    end
  end

  def self.buildNameKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}.name"
  end
  def buildNameKey
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}.name"
  end

  def self.buildBaseKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}"
  end
  def buildBaseKey
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}"
  end

  # get parent record for this item (by hierarchy code as appropriate)
  def getParentRec
    outcomes = Tree.where(
      tree_type_id: self.tree_type_id,
      version_id: self.version_id,
      subject_id: self.subject_id,
      grade_band_id: self.grade_band_id,
      code: self.parentCode
    )

    if outcomes.count == 0
      return nil
    else
      return outcomes.first
    end
  end

  # get all parent records for this item as appropriate (e.g. Area, Componrnt, and Outcome for indicator record)
  def getAllParents
    parents = []
    parent = self.getParentRec
    while parent.present? do
      parents << parent
      parent = parent.getParentRec
    end
    return parents
  end

  # get all translation name keys needed for this record and parents (Area, Component and Outcome)
  def getAllTransNameKeys
    parents = self.getAllParents
    allRecs = parents.concat([self])
    treeKeys = (allRecs).map { |rec| rec.name_key}
  end


  # Tree.find_or_add_code_in_tree
  #   treeTypeRec - tree type 'OTC' record
  #   versionRec - version 'v01' record
  #   subjectRec - subject record
  #   gradeBandRec - grade band record
  #   fullCode - code including parent codes (e.g. 1.1.1.a for a indicator).
  #   parentRec - parent (area for component, component for outcome, outcome for indicator)
  #   matchRec - last record processed (at this depth), to prevent attempting to add more than once.
  def self.find_or_add_code_in_tree(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode, parentRec, matchRec)
    # if this record is the same as matchRec, then it was already updated.
    matchCode = (matchRec ? matchRec.code : '')
    # name_key = Tree.buildNameKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    if fullCode == matchCode
      return fullCode, matchRec, BaseRec::REC_SKIP, "#{fullCode}"
    else
      # get the tree records for this hierarchy item
  #   where()
      matched_codes = Tree.where(
        tree_type_id: treeTypeRec.id,
        version_id: versionRec.id,
        subject_id: subjectRec.id,
        grade_band_id: gradeBandRec.id,
        code: fullCode
        )
      if matched_codes.count == 0
        # It has not been uploaded yet.  create it.
        tree = Tree.new
        tree.tree_type_id = treeTypeRec.id
        tree.version_id = versionRec.id
        tree.subject_id = subjectRec.id
        tree.grade_band_id = gradeBandRec.id
        tree.code = fullCode
        # fill in parent id if parent passed in, and parent codes match.
        tree.name_key = Tree.buildNameKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
        tree.base_key = Tree.buildBaseKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
        ret = tree.save
        if tree.errors.count > 0
          Rails.logger.error("ERROR: saving hierarchy item: #{fullCode} returned errors: #{tree.errors.full_messages}")
          return fullCode, nil, BaseRec::REC_ERROR, tree.errors.full_messages
        else
          return fullCode, tree, BaseRec::REC_ADDED, "#{fullCode}"
        end
      elsif matched_codes.count == 1
        Rails.logger.error("ERROR: tree item matched already.")
        # it already exists, skip
        matched = matched_codes.first
        if matched.name_key.blank?
          # fixed if existing record is missing translation key or parent record id
          matched.name_key = matched.buildNameKey
          matched.base_key = matched.buildBaseKey
          matched.save
          # to do - do we need error checking here?
        end
        return fullCode, matched_codes.first, BaseRec::REC_NO_CHANGE, "#{fullCode}"
      else
        # too many matching items in database: system error.
        err_str = "Too Many items match in tree: #{@upload.subject_id}, grade_band_id: #{@upload.grade_band_id}, code: #{fullCode}"
        Rails.logger.error("ERROR: #{err_str} ")
        return fullCode, nil, BaseRec::REC_ERROR, err_str
      end # if
    end # if code == matchCode
  end

end
