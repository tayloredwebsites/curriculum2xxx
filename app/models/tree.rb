class Tree < BaseRec


  belongs_to :tree_type
  belongs_to :version
  belongs_to :subject
  belongs_to :grade_band
  belongs_to :parent, class_name: "Tree", foreign_key: "parent_id", optional: true

  # does not seem to be working ?
  # has_many :my_translations

  # are these necessary?
  validates :tree_type, presence: true
  validates :version, presence: true
  validates :subject, presence: true
  validates :grade_band, presence: true

  validates :code, presence: true, allow_blank: false

  # scope for hard coded variables
  scope :otc_tree, -> {
    where(tree_type_id: TREE_TYPE_ID, version_id: VERSION_ID)
  }
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
      puts "arr: #{arr.inspect}"
      puts "arr.join('.'): #{arr.join('.').inspect}"
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

  def self.buildTranslationKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}.name"
  end

  def buildTranslationKey
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}.name"
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
    translation_key = Tree.buildTranslationKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    if fullCode == matchCode
      return fullCode, matchRec, BaseRec::REC_SKIP, "#{fullCode}"
    else
      # get the tree records for this hierarchy item
      matched_codes = Tree.otc_tree.where(subject_id: subjectRec.id, grade_band_id: gradeBandRec.id, code: fullCode)
      if matched_codes.count == 0
        # It has not been uploaded yet.  create it.
        tree = Tree.new
        tree.tree_type_id = treeTypeRec.id
        tree.version_id = versionRec.id
        tree.subject_id = subjectRec.id
        tree.grade_band_id = gradeBandRec.id
        tree.code = fullCode
        # fill in parent id if parent passed in, and parent codes match.
        tree.parent_id = (parentRec.present? && tree.parentCode == parentRec.code) ? parentRec.id : nil
        tree.translation_key = Tree.buildTranslationKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
        ret = tree.save
        if tree.errors.count > 0
          Rails.logger.error("ERROR: saving hierarchy item: #{fullCode} returned errors: #{tree.errors.full_messages}")
          return fullCode, nil, BaseRec::REC_ERROR, tree.errors.full_messages
        else
          return fullCode, tree, BaseRec::REC_ADDED, "#{fullCode}"
        end
      elsif matched_codes.count == 1
        # it already exists, skip
        matched = matched_codes.first
        if matched.translation_key.blank? || matched.parent_id.blank?
          # fixed if existing record is missing translation key or parent record id
          matched.translation_key = matched.buildTranslationKey
          matched.parent_id = parentRec.id if (parentRec.present? && matched.parentCode == parentRec.code)
          matched.save
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
