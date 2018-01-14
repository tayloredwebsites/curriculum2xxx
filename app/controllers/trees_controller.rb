class TreesController < ApplicationController

  before_action :authenticate_user!
  before_action :get_locale
  before_action :find_tree, only: [:show, :edit, :update]

  def index
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)
    @tree = Tree.new
    @otcTree = ''
    respond_to do |format|
      format.html
      format.json { render json: {subjects: @subjects, grade_bands: @gbs}}
    end

  end

  def index_listing
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)
    @tree = Tree.new

    @subj = params[:subject_id].present? ? Subject.find(params[:subject_id]) : nil
    @gb = params[:grade_band_id].present? ? GradeBand.find(params[:grade_band_id]) : nil
    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    # note: Active Record had problems with placeholder conditions in join clause.
    #  - Since @Locale_code is from code, placing it directly in condition is safe (see application_controller.rb)
    # Left join not working, since translation table is owned by gem, and am having trouble inheriting it into MyTranslations.
    # listing = listing.joins("LEFT JOIN translations ON (trees.translation_key = translations.key AND translations.locale = '#{@locale_code}')")
    listing = listing.where(subject_id: @subj.id) if @subj.present?
    listing = listing.where(grade_band_id: @gb.id) if @gb.present?
    # listing = listing.otc_listing
    @trees = listing.all

    # to do - review the pre-fetch the translations for this listing:
    # each translation lookup still takes one or two tenths of a millisecond even after pre-fetch
    # total for development testing file is 2.6 seconds, with or without pre-fecth.
    # leaving code in, in case it helps in production.
    translation_keys= @trees.pluck(:translation_key)
    @translations = Translation.where(locale: @locale_code, key: translation_keys).all

    otcHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      trans = Translation.where(locale: @locale_code, key: tree.translation_key)
      translation = trans.count > 0 ? trans.first.value : '*missing*'
      areaHash = {}
      depth = tree.depth
      case depth
      when 1
        newHash = {text: "#{BaseRec::UPLOAD_RPT_LABELS[0]} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # add area if not there already
        otcHash[tree.area] = newHash if !otcHash[tree.area].present?
      when 2
        newHash = {text: "#{BaseRec::UPLOAD_RPT_LABELS[1]} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise "ERROR: system error, missing area item in report tree."
        end
        addNodeToArrHash(otcHash[tree.area], tree.subCode, newHash)

      when 3
        newHash = {text: "#{BaseRec::UPLOAD_RPT_LABELS[2]} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise "ERROR: system error, missing area item in report tree."
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise "ERROR: system error, missing component item in report tree."
        end
        addNodeToArrHash(otcHash[tree.area][:nodes][tree.component], tree.subCode, newHash)

      when 4
        newHash = {text: "#{BaseRec::UPLOAD_RPT_LABELS[3]} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if otcHash[tree.area].blank?
          raise "ERROR: system error, missing area item in report tree."
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise "ERROR: system error, missing component item in report tree."
        elsif otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome].blank?
          raise "ERROR: system error, missing component item in report tree."
        end
        addNodeToArrHash(otcHash[tree.area][:nodes][tree.component][:nodes][tree.outcome], tree.subCode, newHash)

      else
        raise "build treeview json code not an area or component #{tree.code} at id: #{tree.id}"
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
            a4 = {text: outc[:text], href: "/trees/#{outc[:id]}", setting: 'set'}
            outc[:nodes].each do |key3, indic|
              a5 = {text: indic[:text], href: "/trees/#{indic[:id]}", setting: 'set'}
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

    # convert array of areas into json to put into bootstrap treeview
    @otcJson = otcArrHash.to_json
    respond_to do |format|
      format.html
      format.json { render json: {trees: @trees, subjects: @subjects, grade_bands: @gbs}}
    end

  end

  def new
    @tree = Tree.new()
  end

  def create
    @tree = Tree.new(tree_params)
    if @tree.save
      flash[:success] = "tree created."
      # I18n.backend.reload!
      redirect_to trees_url
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @tree.update(tree_params)
      flash[:notice] = "Tree  updated."
      # I18n.backend.reload!
      redirect_to trees_url
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
      :code,
      :parent_id
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
