class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_type_and_version

  private

  def get_locale
    @locale_code = BaseRec::LOCALE_EN # params[:locale_id] or user.get_locale
  end

  def set_type_and_version
    @treeTypeRec = TreeType.find(BaseRec::TREE_TYPE_ID)
    if @treeTypeRec.blank?
      raise "ERROR missing Tree Type Record"
    elsif @treeTypeRec.code != BaseRec::TREE_TYPE_CODE
      raise "ERROR invalid Tree Type Code"
    end
    @versionRec = Version.find(BaseRec::VERSION_ID)
    if @versionRec.blank?
      raise "ERROR missing Version Record"
    elsif @versionRec.code != BaseRec::VERSION_CODE
      raise "ERROR invalid Version Code"
    end
  end

end
