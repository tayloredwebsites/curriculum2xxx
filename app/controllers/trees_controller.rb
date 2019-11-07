class TreesController < ApplicationController

  before_action :find_tree, only: [:show, :show_outcome, :edit, :update]
  before_action :authenticate_user!, only: [:reorder]
  
  def index
    index_listing
  end

  def index_listing
    # to do - refactor this
    @subjects = {}
    subjIds = {}
    Subject.all.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
    end
    @gbs = GradeBand.all
    # @gbs_upper = GradeBand.where(code: ['9','13'])

    # get subject from tree param or from cookie (app controller getSubjectCode)
    if params[:tree].present? && tree_params[:subject_id].present?
      @subj = subjIds[tree_params[:subject_id]]
      Rails.logger.debug("*** index_listing params ID: #{tree_params[:subject_id]}")
    elsif @subject_code.present? && @subjects[@subject_code].present?
      @subj = @subjects[@subject_code]
      Rails.logger.debug("*** index_listing @subject_code: #{@subject_code.inspect}")
    else
      subjCode, @subj = @subjects.first
      Rails.logger.debug("*** index_listing no match: #{subjCode} #{@subj.inspect}")
    end

    Rails.logger.debug("*** @subject_code: #{@subject_code.inspect}")
    Rails.logger.debug("*** @subj: #{@subj.inspect}")
    Rails.logger.debug("*** @subj.abbr(@locale_code): #{@subj.abbr(@locale_code).inspect}")
    setSubjectCode(@subj.code)

    # get gradeBand from tree param or from cookie (app controller getSubjectCode)
    if params[:tree].present? && tree_params[:grade_band_id] == '0'
      Rails.logger.debug("*** defaults: #{@grade_band_code}")
      @gb = nil
      @grade_band_code = GradeBand.all.first
    elsif params[:tree].present? && tree_params[:grade_band_id].present?
      @gb = GradeBand.find(tree_params[:grade_band_id])
      @grade_band_code = @gb.code
      Rails.logger.debug("*** index_listing gb params ID: #{tree_params[:grade_band_id]}, code: #{@gb.code}")
    elsif @grade_band_code.present?
      @gb = GradeBand.where(code: @grade_band_code).first
      Rails.logger.debug("*** index_listing @grade_band_code: #{@grade_band_code.inspect}")
      @grade_band_code = @gb.code
    else
      # defaults to all
      Rails.logger.debug("*** defaults: #{@grade_band_code}")
      @gb = nil
      @grade_band_code = GradeBand.all.first
    end
    setGradeBandCode(@grade_band_code) if @gb
    Rails.logger.debug("*** @grade_band_code: #{@grade_band_code.inspect}")
    Rails.logger.debug("*** @gb: #{@gb.inspect}")

    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    listing = listing.where(subject_id: @subj.id) if @subj.present?
    listing = listing.where(grade_band_id: @gb.id) if @gb.present?
    # Note: sort order does matter for sequence of siblings in tree.
    @trees = listing.joins(:grade_band).order("grade_bands.sort_order, trees.sort_order, code").all

    # @tree is used for filtering form
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @tree.subject_id = @subj.id if @subj.present?
    @tree.grade_band_id = @gb.id if @gb.present?

    # Translations table no longer belonging to I18n Active record gem.
    # note: Active Record had problems with placeholder conditions in join clause.
    # Consider having Translations belong_to trees and sectors.
    # Current solution: get translation from hash of pre-cached translations.
    base_keys= @trees.map { |t| "#{t.base_key}.name" }
    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: base_keys)
    translations.each do |t|
      # puts "t.key: #{t.key.inspect}, t.value: #{t.value.inspect}"
      @translations[t.key] = t.value
    end

    treeHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.name_key]
      areaHash = {}
      depth = tree.depth
      case depth

      when 1
        newHash = {text: "#{I18n.translate('app.labels.grade_band')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # add grade (band) if not there already
        treeHash[tree.codeArrayAt(0)] = newHash if !treeHash[tree.codeArrayAt(0)].present?

      when 2
        newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.codeArrayAt(1)}: #{translation}", id: "#{tree.id}", nodes: {}}
        puts ("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(1)} to area #{tree.codeArrayAt(0)} in treeHash")
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)], tree.subCode, newHash)

      when 3
        newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.codeArrayAt(2)}: #{translation}", id: "#{tree.id}", nodes: {}}
        puts ("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(2)} to area #{tree.codeArrayAt(1)} in treeHash")
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)], tree.subCode, newHash)

      when 4
        newHash = {text: "#{I18n.translate('app.labels.outcome')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        end
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)], tree.subCode, newHash)

      when 5
        # # to do - look into refactoring this
        # # check to make sure parent in hash exists.
        # Rails.logger.debug("*** tree index_listing: #{tree.inspect}")
        # Rails.logger.debug("*** tree.name_key: #{tree.name_key}")
        # Rails.logger.debug("*** Translation for tree.name_key: #{Translation.where(locale: 'en', key: tree.name_key).first.inspect}")
        newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # Rails.logger.debug("indicator newhash: #{newHash.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)].blank?
          Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
          raise I18n.t('trees.errors.missing_outcome_in_tree', treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)])
        end
        Rails.logger.debug("*** translation: #{translation.inspect}")
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)], tree.codeArrayAt(4), newHash)

      else
        raise I18n.t('translations.errors.tree_too_deep_id', id: tree.id)
      end
    end
    # convert tree of record codes so that nodes are arrays not hashes for conversion to JSON
    # puts ("+++ treeHash: #{JSON.pretty_generate(treeHash)}")
    otcArrHash = []
    treeHash.each do |key1, area|
      a2 = {text: area[:text], href: "javascript:void(0);"}
      if area[:nodes]
        area[:nodes].each do |key2, comp|
          a3 = {text: comp[:text], href: "javascript:void(0);"}
          comp[:nodes].each do |key3, outc|
            a4 = {text: outc[:text], href: "javascript:void(0);", setting: 'outcome'}
            outc[:nodes].each do |key4, indic|
              a5 = {text: indic[:text], href: tree_path(indic[:id]), setting: 'indicator'}
              a4[:nodes] = [] if a4[:nodes].blank?
              a4[:nodes] << a5
            end
            a3[:nodes] = [] if a3[:nodes].blank?
            a3[:nodes] << a4
          end
          a2[:nodes] = [] if a2[:nodes].blank?
          a2[:nodes] << a3
        end
      end
      # done with area, append it to otcArrHash
      otcArrHash << a2
    end
    # puts ("+++ otcArrHash: #{JSON.pretty_generate(otcArrHash)}")

    # convert array of areas into json to put into bootstrap treeview
    @otcJson = otcArrHash.to_json
    respond_to do |format|
      format.html { render 'index'}
      format.json { render json: {trees: @trees, subjects: @subjects, grade_bands: @gbs}}
    end

  end

  def new
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
  end

  # def create
  #   Rails.logger.debug("Tree.create params: #{tree_params.inspect}")
  #   @tree = Tree.new(tree_params)
  #   if @tree.save
  #     flash[:success] = "tree created."
  #     # I18n.backend.reload!
  #     redirect_to trees_path
  #   else
  #     render :new
  #   end
  # end

  # def show
  #   # to do - refactor so this and show_outcome are same action and view
  #   # get all translation keys for this record and above
  #   treeKeys = @tree.getAllTransNameKeys
  #   # get all translation keys for all sectors related to it
  #   @tree.sectors.each do |s|
  #     treeKeys << s.name_key
  #   end
  #   # get the translation key for the related sectors explanation
  #   treeKeys << "#{@tree.base_key}.explain"
  #   @translations = Translation.translationsByKeys(@locale_code, treeKeys)
  #   all_codes = JSON.load(@tree.matching_codes)
  #   trans = @translations[@tree.buildNameKey]
  #   all_translations = JSON.load(trans)
  #   @group_indicators = []
  #   all_codes.each_with_index do |c, ix|
  #     thisCode = @tree.codeByLocale(@locale_code, ix)
  #     @group_indicators << [thisCode, all_translations[ix]] if all_translations.length > ix
  #   end
  # end

  def sequence
    index_prep

    @s_o_hash = Hash.new  { |h, k| h[k] = [] }
    @subjects = {}
    subjIds = {}
    subjects = Subject.all
    subjects.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
      @s_o_hash[s.code] = []
    end

    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @trees = listing.joins(:grade_band).order("trees.sequence_order, code").all
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )

    treeHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}

    @relations = Hash.new { |h, k| h[k] = [] }
    relations = TreeTree.active
    relations.each do |rel|
      @relations[rel.tree_referencer_id] << rel
    end

    # Translations table no longer belonging to I18n Active record gem.
    # note: Active Record had problems with placeholder conditions in join clause.
    # Consider having Translations belong_to trees and sectors.
    # Current solution: get translation from hash of pre-cached translations.
    base_keys= @trees.map { |t| "#{t.base_key}.name" }
    base_keys =  base_keys | subjects.map { |s| "#{s.base_key}.name" }
    base_keys = base_keys | subjects.map { |s| "#{s.base_key}.abbr" }
    base_keys = base_keys | relations.map { |r| r.explanation_key }

    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: base_keys)
    translations.each do |t|
      # puts "t.key: #{t.key.inspect}, t.value: #{t.value.inspect}"
      @translations[t.key] = t.value
    end

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.name_key]
      areaHash = {}
      depth = tree.depth
      case depth

      # when 1
      #   newHash = {text: "#{I18n.translate('app.labels.grade_band')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   # add grade (band) if not there already
      #   treeHash[tree.codeArrayAt(0)] = newHash if !treeHash[tree.codeArrayAt(0)].present?

      # when 2
      #   newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.codeArrayAt(1)}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   puts ("+++ codeArray: #{tree.codeArray.inspect}")
      #   if treeHash[tree.codeArrayAt(0)].blank?
      #     raise I18n.t('trees.errors.missing_grade_in_tree')
      #   end
      #   Rails.logger.debug("*** #{tree.codeArrayAt(1)} to area #{tree.codeArrayAt(0)} in treeHash")
      #   addNodeToArrHash(treeHash[tree.codeArrayAt(0)], tree.subCode, newHash)

      # when 3
      #   newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.codeArrayAt(2)}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   puts ("+++ codeArray: #{tree.codeArray.inspect}")
      #   if treeHash[tree.codeArrayAt(0)].blank?
      #     raise I18n.t('trees.errors.missing_grade_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
      #     raise I18n.t('trees.errors.missing_area_in_tree')
      #   end
      #   Rails.logger.debug("*** #{tree.codeArrayAt(2)} to area #{tree.codeArrayAt(1)} in treeHash")
      #   addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)], tree.subCode, newHash)

      when 4
        newHash = {
          text: "#{tree.code}: #{translation}", 
          id: "#{tree.id}",
          connections: @relations[tree.id], 
          nodes: {}
        }
        # if treeHash[tree.codeArrayAt(0)].blank?
        #   raise I18n.t('trees.errors.missing_grade_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
        #   raise I18n.t('trees.errors.missing_area_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
        #   raise I18n.t('trees.errors.missing_component_in_tree')
        #end
        @s_o_hash[tree.subject.code] << newHash
        #addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)], tree.subCode, newHash)

      # when 5
      #   # # to do - look into refactoring this
      #   # # check to make sure parent in hash exists.
      #   # Rails.logger.debug("*** tree index_listing: #{tree.inspect}")
      #   # Rails.logger.debug("*** tree.name_key: #{tree.name_key}")
      #   # Rails.logger.debug("*** Translation for tree.name_key: #{Translation.where(locale: 'en', key: tree.name_key).first.inspect}")
      #   newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   # Rails.logger.debug("indicator newhash: #{newHash.inspect}")
      #   if treeHash[tree.codeArrayAt(0)].blank?
      #     raise I18n.t('trees.errors.missing_grade_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
      #     raise I18n.t('trees.errors.missing_area_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
      #     raise I18n.t('trees.errors.missing_component_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)].blank?
      #     Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
      #     raise I18n.t('trees.errors.missing_outcome_in_tree', treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)])
      #   end
      #   Rails.logger.debug("*** translation: #{translation.inspect}")
      #   addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)], tree.codeArrayAt(4), newHash)

      else
        # raise I18n.t('translations.errors.tree_too_deep_id', id: tree.id)
      end
    end
    # convert tree of record codes so that nodes are arrays not hashes for conversion to JSON
    # puts ("+++ treeHash: #{JSON.pretty_generate(treeHash)}")
    otcArrHash = []
    treeHash.each do |key1, area|
      a2 = {text: area[:text], href: "javascript:void(0);"}
      if area[:nodes]
        area[:nodes].each do |key2, comp|
          a3 = {text: comp[:text], href: "javascript:void(0);"}
          comp[:nodes].each do |key3, outc|
            a4 = {text: outc[:text], href: "javascript:void(0);", setting: 'outcome'}
            outc[:nodes].each do |key4, indic|
              a5 = {text: indic[:text], href: tree_path(indic[:id]), setting: 'indicator'}
              a4[:nodes] = [] if a4[:nodes].blank?
              a4[:nodes] << a5
            end
            a3[:nodes] = [] if a3[:nodes].blank?
            a3[:nodes] << a4
          end
          a2[:nodes] = [] if a2[:nodes].blank?
          a2[:nodes] << a3
        end
      end
      # done with area, append it to otcArrHash
      otcArrHash << a2
    end
    # puts ("+++ otcArrHash: #{JSON.pretty_generate(otcArrHash)}")

    # convert array of areas into json to put into bootstrap treeview
    @otcJson = otcArrHash.to_json

    respond_to do |format|
      format.html { render 'sequence'}
    end
  end

  def show
    process_tree = false
    Rails.logger.debug("*** depth: #{@tree.depth}")
    case @tree.depth
      # process this tree item, is at proper depth to show detail
    when 4
      # process this single indicator
      @trees = [@tree]
      process_tree = true
    when 3
      # get all indicators for this outcome and single grade band
      @trees = Tree.where('depth = 3 AND tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code LIKE ?', @tree.tree_type_id, @tree.version_id, @tree.subject_id, @tree.grade_band_id, "#{@tree.code}%")
      process_tree = true
    else
      # not a detail page, go back to index page
      index_prep
      render :index

    end

    if process_tree
      editMe = params['editme']
      @editMe = false
      if editMe && editMe == @tree.id.to_s
        @editMe = true
      end
      Rails.logger.debug("*** @editMe: #{@editMe.inspect}")
      # prepare to output detail page
      @indicators = []
      @subjects = Subject.all.order(:code)
      subjById = @subjects.map{ |rec| [rec.id, rec.code]}
      @subjById = Hash[subjById]
      Rails.logger.debug("*** @subjById: #{@subjById.inspect}")
      relatedBySubj = @subjects.map{ |rec| [rec.code, []]}
      @relatedBySubj = Hash[relatedBySubj]
      Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
      # get all translation keys for this learning outcome
      treeKeys = @tree.getAllTransNameKeys
      if @tree.depth == 4
        # when outcome level, get children (indicators), to in outcome page
        @tree.getAllChildren.each do |c|
          treeKeys << c.name_key
        end
      end
      Rails.logger.debug("*** treeKeys: #{treeKeys.inspect}")
      @trees.each do |t|
        Rails.logger.debug("*** tree: #{t.base_key}")
        # get translation key for this indicator
        treeKeys << t.name_key
        Rails.logger.debug("*** add tree name_key: #{t.name_key}")
        # get translation key for each sector for this indicator
        if treeKeys
          t.sector_trees.each do |st|
            Rails.logger.debug("*** add sector name_key: #{st.sector.name_key}")
            treeKeys << st.sector.name_key
            Rails.logger.debug("*** add sector explanation_key: #{st.explanation_key}")
            treeKeys << st.explanation_key
          end
        end
        # get translation key for each related indicators for this indicator
        Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
        t.tree_referencers.each do |r|
          Rails.logger.debug("*** related: #{r.inspect}")
          Rails.logger.debug("*** related tree: #{r.tree_referencee.inspect}")
          rTree = r.tree_referencee
          treeKeys << rTree.name_key
          Rails.logger.debug("*** add related name_key: #{rTree.name_key}")
          treeKeys << r.explanation_key
          Rails.logger.debug("*** add related explanation_key: #{r.explanation_key}")
          subCode = @subjById[rTree.subject_id]
          Rails.logger.debug("*** before: @relatedBySubj[#{subCode}]: #{@relatedBySubj[subCode].inspect}")
          @relatedBySubj[subCode] << {
            code: rTree.code,
            relationship: ((r.relationship == 'depends') ? r.relationship+' on' : r.relationship+' to'),
            tkey: rTree.name_key,
            explanation: r.explanation_key,
            tid: (rTree.depth < 2) ? 0 : rTree.id
          } if !@relatedBySubj[subCode].include?(rTree.code)
          Rails.logger.debug("*** after: @relatedBySubj[#{subCode}]: #{@relatedBySubj[subCode].inspect}")
        end
        # get the translation key for the indicators in the group of matched (indicators)
        JSON.load(t.matching_codes).each do |j|
          Rails.logger.debug("*** add indicator name_key: #{j.name_key}")
          treeKeys << "#{t.buildRootKey}.#{j}.name"
        end
        Rails.logger.debug("*** add explain name_key: #{t.base_key}.explain")
        treeKeys << "#{t.base_key}.explain"
        @indicators << t
      end
      Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
      @translations = Translation.translationsByKeys(@locale_code, treeKeys)
      @translations.each do |k, v|
        Rails.logger.debug("*** @translation1: #{k.inspect}: #{v.inspect}")
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    if @tree.update(tree_params)
      flash[:notice] = "Tree  updated."
      # I18n.backend.reload!
      redirect_to trees_path
    else
      render :edit
    end
  end

  def reorder
    Rails.logger.debug(params[:id_order].inspect)
    count = 1
    ActiveRecord::Base.transaction do
    params[:id_order].each do |id|
      t = Tree.find(id)
      t.sequence_order = count
      t.save
      count += 1
    end
    end
    respond_to do |format|
      format.json {render json: {hello_message: 'hello world'}}
    end
  end

  private

  def find_tree
    @tree = Tree.find(params[:id])
  end

  def tree_params
    params.require(:tree).permit(:id,
      :tree_type_id,
      :version_id,
      :subject_id,
      :grade_band_id,
      :code
    )
  end

  def reorder_params
    params.permit(:id_order)
  end

  def addNodeToArrHash (parent, subCode, newHash)
    if !parent[:nodes].present?
      parent[:nodes] = {}
    end
    # # add hash if not there already
    # if !parent[:nodes][subCode].present?
    #   parent[:nodes][subCode] = newHash
    # end
    # always add (or replace hash)
    parent[:nodes][subCode] = newHash
  end

  def index_prep
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all
    # @gbs_upper = GradeBand.where(code: ['9','13'])
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @otcTree = ''
  end

end
