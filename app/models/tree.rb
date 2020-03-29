class Tree < BaseRec

  # Note: Found english version of letters mixed in with cryllic
  # mapped english version of aejko cyrillic letters to match the corresponding english letter so both versions of the letter would map out properly to the english
  # then mapped cyrillic letters, so english to cyrillic would return cryllic
  INDICATOR_SEQ_ENG = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'a', 'e', 'j', 'k', 'o']
  INDICATOR_SEQ_CYR = ['а', 'б', 'ц', 'д', 'е', 'ф', 'г', 'х', 'и', 'ј', 'к', 'л', 'м', 'н', 'о', 'п', 'a', 'e', 'j', 'k', 'o']
  # hash to return english letter for cyrillic letter
  GET_ENG_IND_H = INDICATOR_SEQ_CYR.zip(INDICATOR_SEQ_ENG).to_h
  # hash to return cyrillic letter for english letter
  GET_CYR_IND_H = INDICATOR_SEQ_ENG.zip(INDICATOR_SEQ_CYR).to_h

  # indicator sequence in cyrillic order (not in western order)
  INDICATOR_CYR_SEQ_CYR = ['а', 'б', 'в', 'г' ,'д' ,'ђ' ,'е' ,'ж' ,'з' ,'и' ,'ј' ,'к' ,'л' ,'љ' ,'м' ,'н', 'a', 'e', 'j', 'k', 'o']
  # hash to return cyrillic letter for english letter in sequence order
  GET_ENG_SEQ_CYR_IND_H = INDICATOR_CYR_SEQ_CYR.zip(INDICATOR_SEQ_ENG).to_h

  belongs_to :tree_type
  belongs_to :version
  belongs_to :subject
  belongs_to :grade_band
  belongs_to :outcome, optional: true

  has_many :tree_referencers, foreign_key: :tree_referencer_id, class_name: 'TreeTree'
  # has_many :tree_referencer_trees, through: :tree_referencers
  has_many :tree_referencees, foreign_key: :tree_referencee_id, class_name: 'TreeTree'
  # has_many :tree_referencee_trees, through: :tree_referencees
  has_many :sector_trees
  has_many :sectors, through: :sector_trees

  has_many :dim_trees
  has_many :dimensions, through: :dim_trees

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

  scope :not_blank, -> { where.not(:base_key => ["", nil]) }
  scope :active, -> { not_blank.where(:active => true) }

  # Field Translations

  ####################################################
  def code_by_ix(ix)
    if depth == 3
      if self.matching_codes.length > ix
        mcs = JSON.load(matching_codes)
        return mcs[ix]
      end
    end
    return code
  end


  def codeArray
    if self.code.present?
      return self.code.split('.')
    else
      return nil
    end
  end

  def codeArrayAt(n)
    if n >= codeArray.length
      return nil
    else
      return self.codeArray[n]
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

  def parentCodes
    arr = self.codeArray
    ret = []
    while arr && arr.length > 0
      arr.pop(1)
      ret << arr.join('.')
    end
    ret
  end

  # overrides of deprecated depth field
  def depth
    return codeArray.length
  end

  # overrides of deprecated name_key field
  def name_key
    return base_key + ".name"
  end

  # def area
  #   return self.codeArray[0]
  # end

  # def component
  #   if self.depth.present? && self.depth > 0
  #     return self.codeArray[1]
  #   else
  #     return nil
  #   end
  # end

  # def outcome
  #   if self.depth.present? && self.depth > 1
  #     return self.codeArray[2]
  #   else
  #     return nil
  #   end
  # end

  # def indicator
  #   if self.depth.present? && self.depth > 2
  #     return self.codeArray[3]
  #   else
  #     return nil
  #   end
  # end

  def self.engIndicatorLetter(letter, seq)
    # convert cyrillic to western alphabet depending upon sequencing
    ret = ''
    if seq == 'c'
      ret = GET_ENG_SEQ_CYR_IND_H[letter]
    else
      ret = GET_ENG_IND_H[letter]
    end
    if ret.present?
      return ret
    else
      return "#{letter}(#{letter.bytes})-INVALID"
    end
  end

  # def self.validCyrIndicatorLetter?(letter)
  #   if INDICATOR_SEQ_CYR.include?(letter)
  #     return true
  #   else
  #     return false
  #   end
  # end

  # return the indicator letter by locale (translating SR to latin equivalent)
  # indicators are mapped in either:
  #   a cyrillic sequenced mapping абвгдђ... to abcde...
  #   or a western sequenced mapping from абцде... to abcde...)
  def self.indicatorLetterByLocale(locale, letter, seq='c')
    if locale == BaseRec::LOCALE_SR
      return Tree.engIndicatorLetter(letter, seq)
    else
      if INDICATOR_SEQ_ENG.include?(letter)
        return letter
      else
        return "#{letter}(#{letter.bytes})-INVALID"
      end
    end
  end

  # def self.cyrIndicatorCode(codeIn)
  #   # indicator code letter is in english - map to cyrillic
  #   codeArray = codeIn.split('.')
  #   if codeArray.length > 3
  #     indicLetter = codeArray[3]
  #     if INDICATOR_SEQ_ENG.include?(indicLetter)
  #       codeArray[3] = GET_CYR_IND_H[indicLetter]
  #       return codeArray.join('.')
  #     end
  #   end
  # end

  def codeByLocale(locale, ix=0)
    retCode = code_by_ix(ix)
    if locale == BaseRec::LOCALE_SR
      return Tree.cyrIndicatorCode(code)
    else
      return retCode
    end
  end

  def self.buildNameKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    # return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}.name"
    return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{fullCode}.name"
  end
  def buildNameKey
    # return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}.name"
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.code}.name"
  end

  def self.buildBaseKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    # return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}"
    return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{fullCode}"
  end
  def buildBaseKey
    # return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}"
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.code}"
  end

  def buildRootKey
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}"
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
    self_code = self.code.split('.')
    self_code.pop(1)
    while self_code.length > 0 do
      puts "self_code: #{self_code}"
      if parent.present?
        parents << parent
        parent = parent.getParentRec
        self_code.pop(1)
      else
        parents << nil
        self_code.pop(1)
        parent = Tree.where(
            tree_type_id: self.tree_type_id,
            version_id: self.version_id,
            subject_id: self.subject_id,
            grade_band_id: self.grade_band_id,
            code: self_code.join(".")
          ).first
      end
    end
    Rails.logger.debug("*** tree parents: #{parents.inspect}")
    return parents
  end

  # get all children records for this item as appropriate (e.g. indicators for outcome record)
  def getAllChildren
    children = Tree.where("tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code like ?", tree_type_id, version_id, subject_id, grade_band_id, code+'.%')
    Rails.logger.debug("*** tree children: #{children.inspect}")
    return children
  end

  # get all translation name keys needed for this record and parents (Area, Component and Outcome)
  def getAllTransNameKeys
    parents = self.getAllParents
    allRecs = parents.concat([self])
    treeKeys = (allRecs).map { |rec| rec.name_key if rec}
  end

  # Tree.find_or_add_code_in_tree
  #   treeTypeRec - tree type 'OTC' record
  #   versionRec - version 'v01' record
  #   subjectRec - subject record
  #   gradeBandRec - grade band record
  #   fullCode - code including parent codes (e.g. 1.1.1.a for a indicator).
  #   depth - record depth - stored in record
  #   sort_order - originally in record read order, is used to adjust for sort issues, and may be used for moving LOs around
  #   sequence_order - originally in record read order, is used to resequence LOs in Sequencing page
  def self.find_or_add_code_in_tree(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode, depth, sort_order, sequence_order)
    # get the tree records for this hierarchy item
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
      tree.base_key = "#{treeTypeRec.code}."\
        "#{versionRec.code}."\
        "#{subjectRec.code}."\
        "#{fullCode}"
      tree.depth = depth
      tree.sort_order = sort_order
      tree.sequence_order = sequence_order
      ret = tree.save
      puts "++++ add tree.base_key: #{tree.base_key}"
      if tree.errors.count > 0
        return fullCode, nil, BaseRec::REC_ERROR, "#{I18n.t('trees.errors.save_curriculum_code_error', code: fullCode)} #{tree.errors.full_messages}"
      else
        return fullCode, tree, BaseRec::REC_ADDED, "#{fullCode}"
      end
    elsif matched_codes.count == 1
      # it already exists, skip
      puts "++++ skip matched_codes[0].base_key: #{matched_codes[0].base_key}"
      return fullCode, matched_codes.first, BaseRec::REC_NO_CHANGE, "#{fullCode}"
    else
      # too many matching items in database: system error.
      err_str = I18n.t('trees.errors.too_many_match_subject_gb_code', subject: @upload.subject_id, gb: @upload.grade_band_id, code: fullCode)
      Rails.logger.error("ERROR: #{err_str} ")
      return fullCode, nil, BaseRec::REC_ERROR, err_str
    end #
  end

  def self.find_code_in_tree(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    # get the tree records for this hierarchy item
    matched_codes = Tree.where(
      tree_type_id: treeTypeRec.id,
      version_id: versionRec.id,
      subject_id: subjectRec.id,
      grade_band_id: gradeBandRec.id,
      code: fullCode
    )
    Rails.logger.debug ("*** find code: #{fullCode}")
    if matched_codes.count == 1
      # it already exists, skip
      matched = matched_codes.first
      return matched
    elsif matched_codes.count == 0
      Rails.logger.error ("ERROR - missing tree rec for: #{subjectRec.code}, #{gradeBandRec.code}, #{fullCode}")
      return nil
    end # if
  end

end
