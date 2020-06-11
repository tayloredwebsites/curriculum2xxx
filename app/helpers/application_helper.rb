module ApplicationHelper

  def unauthorized(message = I18n.translate('app.errors.unauthorized'))
    redirect_to root_path, alert: message
  end

  def current_is_teacher?
    current_user && current_user.is_teacher?
  end

  def current_is_counselor?
    current_user && current_user.is_counselor?
  end

  def current_is_supervisor?
    current_user && current_user.is_supervisor?
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

  def can_edit_type?(type)
    teachers_can_edit = [] #['miscon', 'sector', 'connect', 'resource']
    return current_is_admin? || (current_is_teacher? && teachers_can_edit.include?(type)) ||
      (current_is_counselor? && teachers_can_edit.include?(type)) ||
      (current_is_supervisor? && teachers_can_edit.include?(type))
  end

  def can_edit_any_dims?(treeTypeRec)
    ret = false
    treeTypeRec.dim_codes.split(',').each do |dtype|
      ret = true if can_edit_type?(dtype)
    end
    return ret
  end

  #parse the TreeType.dim_display string and
  #return a hash of which dimensions should get a
  #show page, and which resource types should appear
  #on the page.
  #example of the dim_display param: 'miscon#1#2,bigidea#8#11'
  def dim_display_hash(dim_display)
    ret = {}
    dim_display.split(",").each do |dim_str|
      #item 0 in dim_arr is the dim_code
      #subsequent items are indexes in the
      #Dimension::RESOURCE_TYPES array
      dim_arr = dim_str.split("#")
      ret[dim_arr[0]] = dim_arr[1..dim_arr.length].map { |c| Dimension::RESOURCE_TYPES[c.to_i] }
    end
    return ret
  end

  #################
  #Build data for tree/show partials
  #'grade,unit,lo,weeks,hours,[bigidea]_[essq],[concept]_[skill],[miscon#2#1],{resource#7},<sector>,+treetree+,{resources#1#3#2}'
  def parse_detail_headers(detail_areas, hierarchy_codes)
    detail_areas.each do |a|
      header_area = false
      details = a.split("_") # e.g., [bigidea]_[essq] might be in the same table
      table = {}
      table[:num_cols] = 0
      table[:num_rows] = 1
      table[:title_code_type_action_catsArr] = []
      table[:partial] = "evenly_spaced_details"
      table[:depths] = []
      details.each do |d|
        ttac_arr = []
        table[:num_cols] += 1
        #table building 'evenly_spaced_details' partial
        if d.first == "{" && d.last == "}" #outcome resource(s)
          catCodes = d[1..d.length - 2].split("#")
          resource_types = hierarchy_codes.include?(catCodes[0]) ? Tree::RESOURCE_TYPES : Outcome::RESOURCE_TYPES
          table[:title_code_type_action_catsArr] << [
              "", #title
              resource_types[catCodes[1].to_i], #code
              resource_types[catCodes[1].to_i],
              "edit", #action
              catCodes[1..catCodes.length - 1] #numeric category codes
            ]
          table[:partial] = "resources" if catCodes[0] == "resources"
          table[:depths] << hierarchy_codes.index(catCodes[0])
          @editTypes[resource_types[catCodes[1].to_i]] = {
            :name => (hierarchy_codes.include?(catCodes[0]) ? "tree_resource" : "resource"),
            :codes => catCodes[1..catCodes.length - 1]
          }
        #table building 'evenly_spaced_details' partial
        elsif d.first == "[" && d.last == "]" #dimtree
          catCodes = d[1..d.length - 2].split("#")
          table[:title_code_type_action_catsArr] << [
              @dimTypeTitleByCode[catCodes[0]], #title
              catCodes[0], #code
              "dimtree", #edit_type
              "edit", #action
              catCodes[1..catCodes.length - 1] #numeric category codes
            ]
          table[:num_cols] += catCodes.length - 1
          table[:num_rows] =  [@detailsHash[catCodes[0]].length, table[:num_rows]].max
          table[:depths] << nil
          @editTypes[catCodes[0]] = {
            :name => "dimtree",
            :codes => catCodes[1..catCodes.length - 1]
          }
        #table building 'evenly_spaced_details' partial
        elsif d.first == "<" && d.last == ">" #sector
          catCode = d[1..d.length - 2]
          table[:title_code_type_action_catsArr] << [
              @sectorName, #title
              catCode, #code
              "sector", #edit_type
              "create", #action
              nil #category codes not implemented for sectors
            ]
          table[:num_rows] =  [@detailsHash[catCode].length, table[:num_rows]].max
          table[:depths] << nil
          @editTypes[catCode] = { :name => "sector"}
        #table uses 'treetree' partial
        elsif d.first == "+" && d.last == "+" #treetree
          catCode = d[1..d.length - 2]
          table[:title_code_type_action_catsArr] << [
              I18n.t(
                'trees.labels.outcome_connections',
                outcome: @hierarchies[@tree.depth - 1].pluralize
              ), #title
              catCode, #code
              "treetree", #edit_type
              "create", #action
              nil #category codes not implemented for sectors
            ]
          table[:num_cols] += 3
          table[:partial] = 'treetree' #treetrees have a special partial
          table[:depths] << nil
          @editTypes[catCode] = {:name => 'treetree'}
        else
          header_area = true
        end
      end #details in table
      @detailTables << table if !header_area
      @detail_headers << {type: 'header', name: a, depth: hierarchy_codes.index(a) } if header_area
      #@detail_areas << {type: detail_type, name: detail, codes: category_codes} if detail_type != 'header'
    end
  end

end
