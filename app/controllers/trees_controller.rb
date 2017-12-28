class TreesController < ApplicationController
  before_action :find_tree, only: [:show, :edit, :update]

  def index
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)
    @tree = Tree.new
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
