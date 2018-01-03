class TreesController < ApplicationController
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
      tree_type_id: ApplicationRecord::OTC_TREE_TYPE_ID,
      version_id: ApplicationRecord::OTC_VERSION_ID
    )
    listing = listing.where(subject_id: @subj.id) if @subj.present?
    listing = listing.where(grade_band_id: @gb.id) if @gb.present?
    # listing = listing.otc_listing
    @trees = listing.all
    otcHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}

    # create ruby hash from tree records, to build json for treeview
    @trees.each do |tree|
      areaHash = {}
      depth = tree.depth
      case depth
      when 1
        newHash = {text: "#{ApplicationRecord::OTC_UPLOAD_RPT_LABELS[0]}: #{tree.subCode}", nodes: {}}
        # add area if not there already
        otcHash[tree.area] = newHash if !otcHash[tree.area].present?
      when 2
        newHash = {text: "#{ApplicationRecord::OTC_UPLOAD_RPT_LABELS[1]}: #{tree.subCode}", nodes: {}}
        if otcHash[tree.area].blank?
          raise "ERROR: system error, missing area item in report tree."
        end
        addNodeToArrHash(otcHash[tree.area], tree.subCode, newHash)

      when 3
        newHash = {text: "#{ApplicationRecord::OTC_UPLOAD_RPT_LABELS[2]}: #{tree.subCode}", nodes: {}}
        if otcHash[tree.area].blank?
          raise "ERROR: system error, missing area item in report tree."
        elsif otcHash[tree.area][:nodes][tree.component].blank?
          raise "ERROR: system error, missing component item in report tree."
        end
        addNodeToArrHash(otcHash[tree.area][:nodes][tree.component], tree.subCode, newHash)

      else
        raise "build treeview json code not an area or component #{tree.code} at id: #{tree.id}"
      end
    end
    # copy hash of areas, and all node hashes into arrays
    otcArrHash = []
    otcHash.each do |key1, area|
      a2 = {text: area[:text]}
      if area[:nodes]
        area[:nodes].each do |key2, comp|
          a3 = {text: "#{comp[:text]}"}
          comp[:nodes].each do |key3, outc|
            a4 = {text: "#{outc[:text]}"}
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
    puts "@otcJson: #{@otcJson}"

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
