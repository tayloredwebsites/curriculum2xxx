module ApplicationHelper

  # subject select options built for options_for_select
  def subjectsOptions(selected_id)
    # ret = [['All', '']]
    ret = []
    retSelName = ''
    Subject.all.each do |s|
      # ret << [ @translations["sector.#{s.code}.name"], s.id ]
      ret << [s.code, s.id]
      retSelName = s.code if s.id.to_s == selected_id.to_s
    end
    return ret, retSelName
  end

  # grade band select options built for options_for_select
  def gradeBandsOptions(selected_id)
    # ret = [['All', '']]
    ret = []
    retSelName = ''
    GradeBand.all.each do |gb|
      # ret << [ @translations["sector.#{s.code}.name"], s.id ]
      ret << [gb.code, gb.id]
      retSelName = gb.code if gb.id.to_s == selected_id.to_s
    end
    return ret, retSelName
  end

  # sectors select options built for options_for_select
  def sectorsOptions(selected_id)
    ret = [['All', '']]
    retSelName = ''
    Sector.all.each do |s|
      ret << [ @translations["sector.#{s.code}.name"], s.id ]
      retSelName = s.code if s.id.to_s == selected_id.to_s
    end
    return ret, retSelName
  end


end
