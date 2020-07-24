class LookupTablesOption < BaseRec

	def self.get_label_key(treeTypeCode, versionCode, table_name)
		return "#{treeTypeCode}.#{versionCode}.table.#{table_name}"
	end

	def name_key
		return "table.#{table_name}.opt_id.#{id}"
	end

  # returns both the (ordered) array of options for the given table
  # and the translation keys to lookup, to build the translations for
  # the dropdown menu
  def self.get_table_array_and_keys(treeTypeCode, versionCode, table_name)
  	ret_array = []
  	translKeys = [get_label_key(treeTypeCode, versionCode, table_name)]
  	where(
  		table_name: table_name
  	).order(
  	  'lookup_code'
  	).each do |l|
      translKeys << l.name_key
  	  ret_array << l
  	end
  	return [ret_array, translKeys]
  end

end