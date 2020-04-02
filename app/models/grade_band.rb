class GradeBand < BaseRec
  MIN_GRADE = 0
  MAX_GRADE = 20

  # Translation Field
  #
  # In the existing data, gradeband translations are associated with a
  # specific TreeType, but do not have a version code. It would probably
  # be a good idea to migrate the current Translations to use a version
  # code in addition to the TreeType code.
  def self.build_name_key(treeTypeCode, gbCode)
    return 'grades.'+treeTypeCode+'.'+gbCode+'.name'
  end

	def get_name_key
	  return 'grades.'+TreeType.find(tree_type_id).code+'.'+code+'.name'
	end
  ######################################################
end
