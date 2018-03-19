class TreesController < ApplicationController

  before_action :find_tree, only: [:show, :edit, :update]

  def index
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @otcTree = ''
    respond_to do |format|
      format.html
      format.json { render json: {subjects: @subjects, grade_bands: @gbs}}
    end

  end

  def index_listing
    # to do - refactor this
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)

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
      when 1
        newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # add area if not there already
        otcHash[tree.area] = newHash if !otcHash[tree.area].present?
      when 2
        newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        end
        addNodeToArrHash(otcHash[tree.area], tree.subCode, newHash)

      when 3
        newHash = {text: "#{I18n.translate('app.labels.outcome')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        end
        addNodeToArrHash(otcHash[tree.area][:nodes][tree.component], tree.subCode, newHash)

      when 4
        # to do - look into refactoring this
        # check to make sure parent in hash exists.
        if otcHash[tree.area].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        elsif otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome].blank?
          raise I18n.t('trees.errors.missing_outcome_in_tree')
        end
        if @gb.present?
          newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
          addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome], tree.subCode, newHash)
        else
          # add grade band level item
          newGradeBand = {text: "#{I18n.translate('app.labels.grade_band_num', num: tree.grade_band.code)}", id: "#{tree.grade_band.id}", nodes: {}}
          addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome], tree.grade_band.code, newGradeBand)
          # add indicator level item
          newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
          addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome][:nodes][tree.grade_band.code], tree.subCode, newHash)
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
            a4 = {text: outc[:text], href: tree_path(outc[:id]), setting: 'outcome'}
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

  def show
    # get all translation keys for this record and above
    treeKeys = @tree.getAllTransNameKeys
    # get all translation keys for all sectors related to it
    @tree.sectors.each do |s|
      treeKeys << s.name_key
    end
    # get the translation key for the related sectors explanation
    treeKeys << "#{@tree.base_key}.explain"
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

end
