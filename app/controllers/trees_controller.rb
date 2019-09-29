class TreesController < ApplicationController

  before_action :find_tree, only: [:show, :show_outcome, :edit, :update]

  def index
    index_prep
    respond_to do |format|
      format.html
      format.json { render json: {subjects: @subjects, grade_bands: @gbs}}
    end

  end

  def index_listing
    # to do - refactor this
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all
    @gbs_upper = GradeBand.where(code: ['9','13'])

    @subj = params[:tree].present? && params[:tree][:subject_id].present? ? Subject.find(params[:tree][:subject_id]) : nil
    @gb = params[:tree].present? && params[:tree][:grade_band_id].present? ? GradeBand.find(params[:tree][:grade_band_id]) : nil

    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    listing = listing.where(subject_id: @subj.id) if @subj.present?
    listing = listing.where(grade_band_id: @gb.id) if @gb.present?
    # Note: sort order does matter for sequence of siblings in tree.
    @trees = listing.order(:code).all

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

      when 2
        newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # add area if not there already
        treeHash[tree.codeArrayAt(1)] = newHash if !treeHash[tree.codeArrayAt(1)].present?

      when 3
        newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.codeArrayAt(2)}: #{translation}", id: "#{tree.id}", nodes: {}}
        puts ("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(2)} to area #{tree.codeArrayAt(1)} in treeHash")
        addNodeToArrHash(treeHash[tree.codeArrayAt(1)], tree.subCode, newHash)

      when 4
        newHash = {text: "#{I18n.translate('app.labels.outcome')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if treeHash[tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        end
        addNodeToArrHash(treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)], tree.subCode, newHash)

      when 5
        # to do - look into refactoring this
        # check to make sure parent in hash exists.
        Rails.logger.debug("*** tree index_listing: #{tree.inspect}")
        Rails.logger.debug("*** tree.name_key: #{tree.name_key}")
        Rails.logger.debug("*** Translation for tree.name_key: #{Translation.where(locale: 'en', key: tree.name_key).first.inspect}")
        newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        Rails.logger.debug("indicator newhash: #{newHash.inspect}")
        if treeHash[tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        elsif treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)].blank?
          Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
          Rails.logger.error "area: #{tree.codeArrayAt(1)}"
          Rails.logger.error treeHash[tree.codeArrayAt(1)]
          Rails.logger.error "component: #{tree.component}"
          Rails.logger.error treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)]
          Rails.logger.error "outcome: #{tree.outcome}"
          Rails.logger.error treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes]
          Rails.logger.error treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)]
          raise I18n.t('trees.errors.missing_outcome_in_tree', treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)])
        end
        Rails.logger.debug("*** translation: #{translation.inspect}")
        addNodeToArrHash(treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)], tree.codeArrayAt(4), newHash)

      else
        raise I18n.t('translations.errors.tree_too_deep_id', id: tree.id)
      end
    end
    # convert tree of record codes so that nodes are arrays not hashes for conversion to JSON
    puts ("+++ treeHash: #{JSON.pretty_generate(treeHash)}")
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
    puts ("+++ otcArrHash: #{JSON.pretty_generate(otcArrHash)}")

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

  def show
    process_tree = false
    Rails.logger.debug("*** depth: #{@tree.depth}")
    case @tree.depth
      # process this tree item, is at proper depth to show detail
    when 5
      # process this single indicator
      @trees = [@tree]
      process_tree = true
    when 4
      # get all indicators for this outcome and single grade band
      @trees = Tree.where('depth = 3 AND tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code LIKE ?', @tree.tree_type_id, @tree.version_id, @tree.subject_id, @tree.grade_band_id, "#{@tree.code}%")
      process_tree = true
    else
      # not a detail page, go back to index page
      index_prep
      render :index

    end

    if process_tree
      # prepare to output detail page
      @indicators = []
      @subjects = Subject.all
      subjById = @subjects.map{ |rec| [rec.id, rec.code]}
      @subjById = Hash[subjById]
      Rails.logger.debug("*** @subjById: #{@subjById.inspect}")
      relatedBySubj = @subjects.map{ |rec| [rec.code, []]}
      @relatedBySubj = Hash[relatedBySubj]
      Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
      # get all translation keys for this learning outcome
      treeKeys = @tree.getAllTransNameKeys
      @trees.each do |t|
        Rails.logger.debug("*** tree: #{t.base_key}")
        # get translation key for this indicator
        treeKeys << t.name_key
        # get translation key for each sector for this indicator
        if treeKeys
          t.sectors.each do |s|
            treeKeys << s.name_key
          end
        end
        # get translation key for each related indicators for this indicator
        Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
        t.related_trees.each do |r|
          Rails.logger.debug("*** related: #{r.inspect}")
          treeKeys << r.name_key
          subCode = @subjById[r.subject_id]
          Rails.logger.debug("*** @relatedBySubj[#{subCode}]: #{@relatedBySubj[subCode].inspect}")
          @relatedBySubj[subCode] << {
            code: r.code,
            tkey: r.name_key,
            tid: (r.depth < 2) ? 0 : r.id
          } if !@relatedBySubj[subCode].include?(r.code)
        end
        # get the translation key for the indicators in the group of matched (indicators)
        JSON.load(t.matching_codes).each do |j|
          treeKeys << "#{t.buildRootKey}.#{j}.name"
        end
        treeKeys << "#{t.base_key}.explain"
        @indicators << t
      end
      Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
      @translations = Translation.translationsByKeys(@locale_code, treeKeys)
    end
  end

  def edit
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

  private

  def find_tree
    @tree = Tree.find(params[:id])
  end

  def tree_params
    params.require('tree').permit(:id,
      :tree_type_id,
      :version_id,
      :subject_id,
      :grade_band_id,
      :code
    )
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
    @gbs_upper = GradeBand.where(code: ['9','13'])
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @otcTree = ''
  end

end
