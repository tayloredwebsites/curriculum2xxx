class DimensionsController < ApplicationController
  before_action :find_dimension, only: [:show, :edit, :update]

  def show
    @editMe = params[:editMe]
    @dim_translation = Translation.find_translation_name(
      @locale_code,
      @dimension.get_dim_name_key,
      ""
    )
    @subject_name = Translation.find_translation_name(
        @locale_code,
        Subject.get_default_name_key(@dimension.subject_code),
        @dimension.subject_code
      )
  end

  def edit
    @dim_resource_category = Dimension.get_resource_name(
      dimension_params[:resource_code],
      @treeTypeRec.code,
      @versionRec.code,
      @locale_code,
      "Missing Category Translation"
    )
  	@dim_resource_name = @dimension.resource_name(
  	  @locale_code,
  	  dimension_params[:resource_code],
  	  ""
	  )
	  @resource_code = dimension_params[:resource_code]
  end

  def update
  	if dimension_params[:resource_code] && dimension_params[:resource_text]
	  	dim_resource_key = @dimension.resource_key(dimension_params[:resource_code])
	  	Translation.find_or_update_translation(
	  	  @locale_code,
	  	  dim_resource_key,
	  	  dimension_params[:resource_text]
	  	)
	  end
    redirect_to dimension_path(@dimension.id, editMe: true)
  end

  private

  def dimension_params
    params.require(:dimension).permit(
      :id,
      :resource_code,
      :resource_text
    )
  end

  def find_dimension
    @dimension = Dimension.find(params[:id])
  end
end