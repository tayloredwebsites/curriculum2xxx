class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_type_and_version

  private

  # set the locale codes in controllers: 'before_action :get_locale'
  def get_locale
    I18n.default_locale = BaseRec::LOCALE_EN
    # to do - set the locale to the user's locale (to be found in the users table)
    I18n.locale = BaseRec::LOCALE_EN
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
