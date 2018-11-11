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
    # Note: sort order does not matter, it is ordered correctly in the conversion to the treeview json.
    @trees = listing.all

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
    name_keys= @trees.pluck(:name_key)
    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: name_keys).all
    translations.each do |t|
      @translations[t.key] = t.value
    end

    otcHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.name_key]
      areaHash = {}
      depth = tree.depth
      case depth

      when 0
        newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # add area if not there already
        otcHash[tree.area] = newHash if !otcHash[tree.area].present?

      when 1
        newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        end
        Rails.logger.debug("*** #{tree.subCode.inspect} to area #{tree.area.inspect} in otcHash")
        addNodeToArrHash(otcHash[tree.area], tree.subCode, newHash)

      when 2
        newHash = {text: "#{I18n.translate('app.labels.outcome')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        end
        addNodeToArrHash(otcHash[tree.area][:nodes][tree.component], tree.subCode, newHash)

      when 3
        # to do - look into refactoring this
        # check to make sure parent in hash exists.
        if otcHash[tree.area].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        elsif otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome].blank?
          Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
          Rails.logger.error "area: #{tree.area}"
          Rails.logger.error otcHash[tree.area]
          Rails.logger.error "component: #{tree.component}"
          Rails.logger.error otcHash[tree.area][:nodes][tree.component]
          Rails.logger.error "outcome: #{tree.outcome}"
          Rails.logger.error otcHash[tree.area][:nodes][tree.component][:nodes]
          Rails.logger.error otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome]
          raise I18n.t('trees.errors.missing_outcome_in_tree', otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome])
        end
        all_translations = translation.present? ? JSON.load(translation) : []
        all_codes = JSON.load(tree.matching_codes)
        if @gb.present?
          # add indicator level item directly under outcome
          all_codes.each_with_index do |c, ix|
            newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.codeByLocale(@locale_code, ix)}: #{all_translations[ix]}", id: "#{tree.id}", nodes: {}}
            addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome], tree.subCode, newHash)
          end
        else
          Rails.logger.debug("*** no @gb present")
          # add grade band level item under outcome
          newGradeBand = {text: "#{I18n.translate('app.labels.grade_band_num', num: tree.grade_band.code)}", id: "#{tree.grade_band.id}", nodes: {}}
          addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome], tree.grade_band.code, newGradeBand)
          # add indicator level item under grade band
          all_codes.each_with_index do |c, ix|
            thisCode = tree.codeByLocale(@locale_code, ix)
            newHash = {text: "#{I18n.translate('app.labels.indicator')} #{thisCode}: #{all_translations[ix]}", id: "#{tree.id}", nodes: {}}
            addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome][:nodes][tree.grade_band.code], thisCode, newHash)
          end
        end

      else
        raise I18n.t('translations.errors.tree_too_deep_id', id: tree.id)
      end
    end
    # convert tree of record codes so that nodes are arrays not hashes for conversion to JSON
    otcArrHash = []
    otcHash.each do |key1, area|
      a2 = {text: area[:text], href: "javascript:void(0);"}
      if area[:nodes]
        area[:nodes].each do |key2, comp|
          a3 = {text: comp[:text], href: "javascript:void(0);"}
          comp[:nodes].each do |key3, outc|
            if @gb.present?
              a4 = {text: outc[:text], href: tree_path(outc[:id]), setting: 'outcome'}
            else
              a4 = {text: outc[:text], href: "javascript:void(0);", setting: 'outcome'}
            end
            if @gb.present?
              outc[:nodes].each do |key4, indic|
                a5 = {text: indic[:text], href: tree_path(indic[:id]), setting: 'indicator'}
                a4[:nodes] = [] if a4[:nodes].blank?
                a4[:nodes] << a5
              end
              a3[:nodes] = [] if a3[:nodes].blank?
              a3[:nodes] << a4
            else
              # all gradebands selected - list gradebands under outcomes (with indicators below)
              outc[:nodes].each do |key4, gb|
                a5 = {text: gb[:text], href: "javascript:void(0);", setting: 'grade_band'}
                gb[:nodes].each do |key5, indic|
                  a6 = {text: indic[:text], href: tree_path(indic[:id]), setting: 'indicator'}
                  a5[:nodes] = [] if a5[:nodes].blank?
                  a5[:nodes] << a6
                end
                a4[:nodes] = [] if a4[:nodes].blank?
                a4[:nodes] << a5
              end
              a3[:nodes] = [] if a3[:nodes].blank?
              a3[:nodes] << a4
            end
          end
          a2[:nodes] = [] if a2[:nodes].blank?
          a2[:nodes] << a3
        end
      end
      # done with area, append it to otcArrHash
      otcArrHash << a2
    end

    # convert array of areas into json to put into bootstrap treeview
    @otcJson = otcArrHash.to_json
    respond_to do |format|
      format.html
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
    case @tree.depth
      # process this tree item, is at proper depth to show detail
    when 3
      # process this single indicator
      @trees = [@tree]
    when 2
      # get all indicators for this outcome and single grade band
      @trees = Tree.where('depth = 3 AND tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code LIKE ?', @tree.tree_type_id, @tree.version_id, @tree.subject_id, @tree.grade_band_id, "#{@tree.code}%")
    else
      # not a detail page, go back to index page
      index_prep
      render :index
    end

    # prepare to output detail page
    @indicators = []
    # get all translation keys for this learning outcome
    treeKeys = @tree.getAllTransNameKeys
    @trees.each do |t|
      # get translation key for this indicator
      treeKeys << t.name_key
      # get translation key for each sector for this indicator
      t.sectors.each do |s|
        treeKeys << s.name_key
      end
      t.subjects.each do |s|
        treeKeys << s.name_key
      end
      # get the translation key for the indicators in the group of matched (indicators)
      JSON.load(t.matching_codes).each do |j|
        treeKeys << "#{t.buildRootKey}.#{j}.name"
      end
      treeKeys << "#{t.base_key}.explain"
      @indicators << t
    end
    @translations = Translation.translationsByKeys(@locale_code, treeKeys)
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
    # add hash if not there already
    if !parent[:nodes][subCode].present?
      parent[:nodes][subCode] = newHash
    end
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
