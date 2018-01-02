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

    # @otc = Version.find(ApplicationRecord::OTC_TREE_TYPE_ID)
    # @ver = Version.find(ApplicationRecord::OTC_VERSION_ID)
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
    newComponentHash = {}

    # ruby hash of tree records to build json for treeview
    @trees.each do |tree|
      depth = tree.depth
      case depth
      when 1
        areaHash = {text: "#{ApplicationRecord::OTC_UPLOAD_RPT_LABELS[0]}: #{tree.subCode}", nodes: {}}
        # add area if not there already
        otcHash[tree.area] = areaHash if !otcHash[tree.area].present?
      when 2
        areaHash = {}
        # get area in report tree (miust be there see depth 1 code)
        if otcHash[tree.area].present?
          areaHash = otcHash[tree.area]
          newComponentHash = {text: "#{ApplicationRecord::OTC_UPLOAD_RPT_LABELS[1]}: #{tree.subCode}", nodes: {}}
          # newComponentHash = {text: "#{tree.subCode}", nodes: {}}
          # add nodes hash if not there already
          if !otcHash[tree.area][:nodes].present?
            otcHash[tree.area][:nodes] = {}
          end
          # add component if not there already
          otcHash[tree.area][:nodes][tree.subCode] = newComponentHash if !otcHash[tree.area][:nodes][tree.subCode].present?
        else
          raise "ERROR: system error, missing area item in report tree."
        end

      else
        raise "build treeview json code not an area or component #{tree.code} at id: #{tree.id}"
      end
    end
    # copy hash of areas, and all node hashes into arrays
    otcArrHash = []
    otcHash.each do |key, area|
      a2 = {text: area[:text], nodes: []}
      if area[:nodes]
        area[:nodes].each do |key, comp|
          a2[:nodes] << {text: "#{comp[:text]}"}
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

end
