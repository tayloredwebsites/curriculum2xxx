class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_type_and_version
  before_action :config_devise_params, if: :devise_controller?

  include ApplicationHelper

  private

  # set the locale codes in controllers: 'before_action :getLocaleCode'
  def getLocaleCode
    I18n.default_locale = BaseRec::LOCALE_EN
    # to do - set the locale to the user's locale (to be found in the users table)
    I18n.locale = BaseRec::LOCALE_EN
    @locale_code = BaseRec::LOCALE_EN # params[:locale_id] or user.getLocaleCode
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

  def config_devise_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :given_name,
      :family_name,
      :govt_level,
      :govt_level_name,
      :municipality,
      :institute_type,
      :institute_name_loc,
      :position_type,
      :subject1,
      :subject2,
      :gender,
      :education_level,
      :work_phone,
      :work_address,
      :terms_accepted
    ])
  end

end
