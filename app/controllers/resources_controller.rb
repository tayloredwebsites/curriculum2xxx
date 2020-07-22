class ResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource, only: [:edit]
  before_action :find_resourceable, only: [:create]

  def new
    @resource = Resource.new(resource_code: resource_params[:resource_code])
    find_resource_type_translation
    @join = resource_params[:user_id] ? UserResource.new(
        user_id: resource_params[:user_id],
        user_resourceable_id: resource_params[:resourceable_id],
        user_resourceable_type: resource_params[:resourceable_type]
      ) : ResourceJoin.new(
        resourceable_id: resource_params[:resourceable_id],
        resourceable_type: resource_params[:resourceable_type],
      )
    @translation = Translation.new()
    render :edit
  end

  def edit
    @translation = Translation.where(
        locale: @locale_code,
        key: @resource.name_key
      ).first || Translation.create(
        locale: @locale_code,
        key: @resource.name_key
      ) if @resource.id
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

  def create
    ActiveRecord::Base.transaction do
      resource = Resource.create(resource_code: resource_params[:resource_code])
      if resource_params[:user_id]
        user_for_join = User.find(resource_params[:user_id])
        UserResource.create( user_resourceable: @resourceable, resource: resource, user: user_for_join ) if @resourceable
      else
        @resourceable.resources << resource if @resourceable
      end
      if translation_params
        Translation.create(
          :locale => @locale_code,
          :key => resource.name_key,
          :value => translation_params[:value],
        )
      end
    end
    render :update
  end

  private

    def resource_params
      if params[:resource]
      params.require(:resource).permit(
        :id,
        :resource_code,
        :resourceable_id,
        :resourceable_type,
        :user_id,
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
      find_resource_type_translation
    end

    def find_resource_type_translation
      @resource_type = Translation.find_translation_name(
        @locale_code,
        Resource.get_type_key(@treeTypeRec.code, @versionRec.code, @resource.resource_code),
        @resource.resource_code
      )
    end

    def find_resourceable
      if resource_params && resource_params[:resourceable_type] &&
      resource_params[:resourceable_id]
        @resourceable = resource_params[:resourceable_type].constantize.find(resource_params[:resourceable_id])
      end
    end
end
