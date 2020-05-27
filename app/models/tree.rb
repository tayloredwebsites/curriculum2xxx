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
  belongs_to :outcome, optional: true, autosave: true

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


###################################################
  # Field Translations

  # overrides of deprecated name_key field
  def name_key
    return base_key + ".name"
  end

  def self.buildNameKey(treeTypeRec, versionRec, subjectRec, gradeBandRec, fullCode)
    # return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}.name"
    return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{fullCode}.name"
  end
  def buildNameKey
    # return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}.name"
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.code}.name"
  end

  def self.buildBaseKey(treeTypeCode, versionCode, subjectCode, fullCode)
    # return "#{treeTypeRec.code}.#{versionRec.code}.#{subjectRec.code}.#{gradeBandRec.code}.#{fullCode}"
    return "#{treeTypeCode}.#{versionCode}.#{subjectCode}.#{fullCode}"
  end
  def buildBaseKey
    # return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}.#{self.code}"
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.code}"
  end

  def buildRootKey
    return "#{self.tree_type.code}.#{self.version.code}.#{self.subject.code}.#{self.grade_band.code}"
  end


  ####################################################
  def update_fields(
    update_type,
    locale_code: 'en',
    name_translation: nil,
    comment: nil,
    weeks: nil,
    hours: nil,
    resource: nil,
    resource_name_arr: nil,
    resource_name_keys: nil,
    tree_tree_id: nil,
    tree_tree_rel: nil,
    tree_tree_active: false,
    sector_id: nil,
    x_sector_tree_id: nil,
    x_dim_tree_id: nil
  )
    begin
      name_translation = name_translation[3..name_translation.length].gsub('<br>', '').gsub('</p>', '').gsub('<p>', '<br>') if name_translation
      Translation.find_or_update_translation(
        locale_code,
        buildNameKey,
        name_translation
      ) if name_translation
      Translation.find_or_update_translation(
        locale_code,
        outcome.get_explain_key,
        comment
      ) if comment
      outcome.update(duration_weeks: weeks.to_i) if weeks
      outcome.update(hours_per_week: hours.to_i) if hours
      Translation.find_or_update_translation(
        locale_code,
        outcome.get_resource_key(update_type),
        resource.split("<script>").join("").split("</script>").join("")
      ) if resource
      if (resource_name_arr && resource_name_keys)
        resource_name_arr.each_with_index do |res_name, i|
          Translation.find_or_update_translation(
            locale_code,
            resource_name_keys[i],
            res_name
          )
        end
      end
      if tree_tree_id
        tree_tree = TreeTree.find(tree_tree_id)
        reciprocal_tree_tree = TreeTree.where(
          :tree_referencee_id => tree_tree.tree_referencer_id,
          :tree_referencer_id => tree_tree.tree_referencee_id
            ).first
        tree_tree.relationship = tree_tree_rel if tree_tree_rel
        tree_tree.active = tree_tree_active
        reciprocal_tree_tree.relationship = TreeTree.reciprocal_relationship(tree_tree_rel)
        reciprocal_tree_tree.active = tree_tree_active
        tree_tree.save
        reciprocal_tree_tree.save
      end
      SectorTree.create(
        tree_id: id,
        sector_id: sector_id
      ) if sector_id
      SectorTree.find(x_sector_tree_id).update(active: false) if x_sector_tree_id
      DimTree.find(x_dim_tree_id).update(active: false) if x_dim_tree_id
      return "success"
    rescue => e
      return e
    end
  end # def update_fields

  # Example of expected structure for the optional params:
  #   localeCode = "en"
  #   hierarchy_codes = ["grade", "sem", "unit", "lo"]
  #   tree_code_format = "subject,grade,lo"
  #   subject_code = "bio"
  # Note: Optional params are present to enable us to avoid
  #       doing a very large number of database lookups,
  #       when formatting many tree codes at once (as on
  #       the maint page)
  def format_code(localeCode = BaseRec::LOCALE_EN, hierarchy_codes = nil, tree_code_format = nil, subject_code = nil, grade_band_code = nil)
    hierarchy_codes = tree_type.hierarchy_codes.split(",") if !hierarchy_codes
    tree_code_format = tree_type.tree_code_format if !tree_code_format
    subject_code = subject.get_abbr(localeCode).downcase if !subject_code
    grade_band_code = grade_band.code if !grade_band_code
    if tree_code_format != ""
      format_str = tree_code_format
    else
      format_str = "subject,#{hierarchy_codes}"
    end
    format_arr = []
    hierarchic_arr = code.split('.').map {|c| c == "" ? "00" : c }
    format_str.split(",").each do |c|
      if c == "subject"
        format_arr << subject_code
      elsif c == "grade"
        format_arr << grade_band_code
      else
        c_index = hierarchy_codes.index(c)
        format_arr << hierarchic_arr[c_index] if hierarchic_arr[c_index]
      end
    end

    return format_arr.join(".")
  end

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

  def parentCode
    arr = self.codeArray
    if arr && arr.length > 0
      arr.pop(1)
      while arr && arr.length > 0 && arr.last == ""
        arr.pop(1)
      end
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

  #idOrderArr should contain ids for
  #every active tree with this subject_id
  def self.update_code_sequence(idOrderArr, localeCode = "en")
    #To Do:
    # => How to deal with deactivated trees? Add "x" to all of the codes? We need a "deactivate" method.

    #To return. Used to update the maint page with jquery.
    tree_codes_changed = []

    translations_hash = {} # h[old_key] = new_key
    #lookup trees by id and by "outc#{outcome_id}"
    trees_hash = Hash.new { |h,k| h[k] = {:rec => nil}}
    treeRecs = where(:id => idOrderArr).order('sort_order')
    outcomeRecs = Outcome.where(:id => treeRecs.pluck("outcome_id").uniq)
    translationKeys = []
    codes_counter_by_depth = Hash.new(nil)
    last_tree_depth = 0
    new_outcome_gb = true
    firstTree = treeRecs.first.attributes
    #if only one GradeBand is shown on the maint page,
    #sort_order_offset will ensure that the sort_orders
    #for this gb won't overlap with the sort_order values
    #of other gbs.
    sort_order_offset = firstTree["sort_order"]
    gb_offset = GradeBand.find(firstTree["grade_band_id"]).min_grade - 1
    codes_counter_by_depth[0] = gb_offset
    treeTypeRec = TreeType.find(firstTree["tree_type_id"])
    treeTypeCode = treeTypeRec.code
    versionCode = Version.find(firstTree["version_id"]).code
    subjectRec = Subject.find(firstTree["subject_id"])
    subjectCode = subjectRec.code
    subjectLocaleCode = subjectRec.get_abbr(localeCode).downcase
    gb_by_id_and_min_grade = {}
    #map treeRecs
    treeRecs.map do |t|
      # puts "mapping tree: #{t.inspect}"
      # puts "rec Id instance of string? #{t.id.instance_of? String}"
      trees_hash[t.id][:rec] = t
      trees_hash["outc#{t.outcome_id}"][:rec] = t if t.outcome_id
      if !gb_by_id_and_min_grade["id#{t.grade_band_id}"]
        gb = GradeBand.find(t.grade_band_id)
        gb_by_id_and_min_grade["id#{t.grade_band_id}"] = gb
        gb_by_id_and_min_grade["min#{gb.min_grade}"] = gb
      end
    end
    idOrderArr.each_with_index do |id, ix|
      # puts "Id instance of string? #{id.instance_of? String}"
      t = trees_hash[id.to_i][:rec]
      #puts "Tree to recode: #{id} #{t.inspect}"
      #############
      #constructing the new tree code
      if (t[:depth] > last_tree_depth && !t.outcome_id) || (new_outcome_gb && t.outcome_id)
        codes_counter_by_depth[t[:depth]] = 1
        new_outcome_gb = false if t.outcome_id
      else #depth == 0 will always end up in this block
        new_outcome_gb = t[:depth] == 0
        if codes_counter_by_depth[t[:depth]].nil?
          codes_counter_by_depth[t[:depth]] = 1
        else
          codes_counter_by_depth[t[:depth]] += 1
        end
      end
      if t[:depth] - 1 > last_tree_depth
        #skipped an optional depth (e.g., unit to lo, skipping a subunit)
        [*(last_tree_depth+1)..(t[:depth]-1)].each do |d|
          codes_counter_by_depth[d] = nil
        end
      end
      last_tree_depth = t[:depth]
      code_arr = []
      [*0..t[:depth]].each { |d| code_arr << (codes_counter_by_depth[d] == nil ? '' : format('%02d', codes_counter_by_depth[d])) }
      new_code = code_arr.join(".")
      #puts "codes_counter_by_depth: #{codes_counter_by_depth.inspect}"
      ############
      #update tree in instance data, but not in db
      ############
      if code_arr[0].to_i != t.code.split(".")[0].to_i
        # if gradeband code has changed, we need to
        # update the grade_band_id for the tree rec
        gb_min_grade = codes_counter_by_depth[0]
        t.grade_band_id = gb_by_id_and_min_grade["min#{gb_min_grade}"].id
      end
      #save old translation name key before
      #updating t.code and t.base_key in
      old_name_key = t.name_key
      t.code = new_code
      t.base_key = Tree.buildBaseKey(treeTypeCode, versionCode, subjectCode, new_code)
      #build new translation name key now that
      #base_key has been reset for this instance of the tree
      new_name_key = t.name_key
      t.sort_order = ix + sort_order_offset
      translationKeys << old_name_key
      translations_hash[old_name_key] = new_name_key
      tree_codes_changed << {tree_id: t.id, new_code: t.format_code(localeCode,
        treeTypeRec.hierarchy_codes.split(","),
        treeTypeRec.tree_code_format,
        subjectLocaleCode,
        gb_by_id_and_min_grade["id#{t.grade_band_id}"].code)} if t.changed_for_autosave?
    end
    outcomeRecs.map do |o|
      old_translation_keys = o.list_translation_keys
      o.base_key = o.get_base_key(
        trees_hash["outc#{o.id}"][:rec].base_key
        )
      new_translation_keys = o.list_instance_translation_keys(o.base_key)
      old_translation_keys.each_with_index do |ok, ix|
        translationKeys << ok
        translations_hash[ok] = new_translation_keys[ix]
      end
    end

    translationRecs = Translation.where(:key => translationKeys)
    translationRecs.each { |tr| tr.key = translations_hash[tr.key] }

    #save translationRecs and treeRecs in a transaction. outcomeRecs should autosave with their associated treeRecs
    ActiveRecord::Base.transaction do
      treeRecs.each { |t| t.save! if t.changed_for_autosave? }
      outcomeRecs.each { |o| o.save! if o.changed_for_autosave? }
      translationRecs.each { |t| t.save! if t.changed_for_autosave? }
    end
    return tree_codes_changed
  end #update_code_sequence

  def self.create_and_insert_tree(tree_params, options = {}, locale_code = "en")
    if tree_params[:sort_order] && tree_params[:subject_id]
      subjectRec = Subject.find(tree_params[:subject_id])
      insert_at = tree_params[:sort_order].to_i
      tree = Tree.new(tree_params)
      outc = Outcome.new(options[:outcome_params]) if options[:outcome_params]
      outc.base_key = Outcome.buildBaseKey(tree.base_key)
      outc.save
      outc.reload
      tree.outcome_id = outc.id
      tree.save
      tree.reload
      translation = Translation.new(
        options[:translation_params]
      ) if options[:translation_params]
      translation.key = tree.name_key
      translation.save
      treesAfterInsert = Tree.where(
        "subject_id = ? AND sort_order >= ?",
        subjectRec.id,
        insert_at
      )
      treesAfterInsert.update_all("sort_order = sort_order + 1")
      idOrderArr = Tree.active.where(
        :subject_id => subjectRec.id,
      ).order('sort_order').pluck('id')
      return update_code_sequence(idOrderArr, locale_code)
    end
  end

  def deactivate_and_extract
    treesAfterExtract
  end


end
