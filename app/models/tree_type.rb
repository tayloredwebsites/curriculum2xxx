class TreeType < BaseRec

  scope :active, -> { where(:active => true) }

  # Translation Field
  def hierarchy_name_key(hierarchy_code)
    return "curriculum.#{code}.hierarchy.#{hierarchy_code}"
  end

  def sector_set_name_key
    return "sector.set.#{get_sector_set_code}.name"
  end

  def title_key
    return "curriculum.#{code}.title"
  end

  def home_page_key
    return "curriculum.#{code}.#{Version.find(version_id).code}.home_page"
  end

  def resources_page_key
    return "curriculum.#{code}.#{Version.find(version_id).code}.rsrc_page"
  end

  def user_form_option_key(version_code, form_field_name, option_num)
    return "#{code}.#{version_code}.user_attr.#{form_field_name}.no.#{option_num}"
  end
  #######################################
  def self.get_sector_set_code(code)
    return code.split(",")[0]
  end

  def get_sector_set_code
    return sector_set_code.split(",")[0]
  end

  def self.versions_hash()
    ret_hash = Hash.new { |hash, key| hash[key] = [] }
    codes_found = []
    active.each do |tree_type|
      begin
        ver = Version.find(tree_type[:version_id])
        if codes_found.include?(tree_type.code.downcase)
          ver_code = ".#{ver.code}"
        else
          codes_found << tree_type.code.downcase
          ver_code = active.where(:code => tree_type.code).count > 1 ? ".#{ver.code}" : ''
        end
        curriculum_code = "#{tree_type.code}#{ver_code}"
        ret_hash[tree_type.id] << { str: curriculum_code, tree_type_id: tree_type.id, version_id: ver.id, working: tree_type.working_status }
      rescue StandardError => e
        puts "Could not find version for treeType record: #{tree_type.inspect} Error: #{e.inspect}"
      end
    end
    ret_hash
  end

  def hide_sectors
    return self.sector_set_code.split(",").length > 1
  end

  def user_form_options(version_code, form_field_name, locale_code)
    puts "!!!GET USER FIELD: #{form_field_name} OPTIONS. ver:#{version_code} loc:#{locale_code}"
    config_str = user_form_config.match(/#{form_field_name}#\d+/)
    if config_str
      puts "CONFIG FOR OPTION: #{config_str}"
      ret =  []
      num_opts = config_str.to_s.split("#")[1].to_i
      puts "NUM OPTS = #{num_opts}"
      [*1..num_opts].each do |num|
        ret << Translation.find_translation_name(
            locale_code,
            user_form_option_key(version_code, form_field_name, num),
            nil
          ) || I18n.translate('translations.errors.missing_translation_for_item')
      end
      return ret
    else
      return nil
    end
  end

end
