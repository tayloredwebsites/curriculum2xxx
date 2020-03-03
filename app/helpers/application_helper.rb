module ApplicationHelper

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

  # subject select options built for options_for_select
  def subjectsOptions(selected_id, options_all=false, tree_type_id)
    if options_all
      ret = [['All', '']]
    else
      ret = []
    end
    Subject.where("tree_type_id = ? AND min_grade < ?", tree_type_id, 999).order("max_grade desc", "min_grade asc", "code").each do |s|
      # ret << [ @translations["sector.#{s.code}.name"], s.id ]
      ret << [s.code, s.id]
    end
    return ret
  end

  # sectors select options built for options_for_select
  def sectorsOptions(selected_id, transl, sector_set_code)
    ret = [['All', '']]
    Sector.where(:sector_set_code => sector_set_code).each do |s|
      # ret << [ transl["sector.#{s.code}.name"], s.id ]
      ret << [ Translation.where(locale: @locale_code, key: s.name_key).first.value, s.id ]
    end
    return ret
  end


end
