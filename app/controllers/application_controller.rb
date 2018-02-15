class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_type_and_version

  def unauthorized(message = I18n.translate('app.errors.unauthorized'))
    redirect_to root_path, alert: message
  end

  def current_is_admin?
    user_is_admin?(current_user)
  end

  def user_is_admin?(current_user)
    if current_user && current_user.is_admin?
      return true
    else
      return false
    end
  end

  def has_same_id?(model1, model2)
    if model1 && model2 && model1.id == model2.id
      return true
    else
      return false
    end
  end

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

end
