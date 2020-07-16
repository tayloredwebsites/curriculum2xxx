class ResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource, only: [:edit]

  def new
    @resource = Resource.create(resource_code: resource_params[:resource_code])
    ResourceJoin.create(
        resource_id: @resource.id,
        resourceable_id: resource_params[:resourceable_id],
        resourceable_type: resource_params[:resourceable_type]
      )
    @translation = Translation.create(
        locale: @locale_code,
        key: @resource.name_key
      )
    render :edit
  end

  def edit
    @resource_type = Translation.find_translation_name(
        @locale_code,
        Resource.get_type_key(@treeTypeRec.code, @versionRec.code, @resource.resource_code),
        @resource.resource_code
      )
    @translation = Translation.where(
        locale: @locale_code,
        key: @resource.name_key
      ).first || Translation.create(
        locale: @locale_code,
        key: @resource.name_key
      )
    respond_to do |format|
      format.js
    end
  end

  def update
    if translation_params && translation_params[:id]
      Translation.update(translation_params[:id], :value => translation_params[:value])
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def resource_params
      if params[:resource]
      params.require(:resource).permit(
        :id,
        :resource_code,
        :resourceable_id,
        :resourceable_type,
      )
      else
        nil
      end
    end

    def translation_params
      if params[:translation]
        params.require(:translation).permit(
          :id,
          :key,
          :value,
          :locale,
        )
      else
       nil
      end
    end

    def find_resource
      @resource = Resource.find(params[:id])
    end
end
