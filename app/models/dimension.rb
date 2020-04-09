class Dimension < BaseRec

  # dim_type field valid options
  BIG_IDEA = 'bigidea'
  MISCONCEPTION = 'miscon'
  ESSENTIAL_QUESTION = 'essq'
  QUESTION = 'question'
  CONCEPT = 'concept'
  COMPETENCY = 'comp'
  STANDARD = 'standard'
  VAL_DIM_TYPES = [BIG_IDEA, MISCONCEPTION, ESSENTIAL_QUESTION]

  validate :valid_dim_type

  has_many :dim_trees
  has_many :trees, through: :dim_trees

  scope :active, -> { where(:active => true) }

  # Translation Field
  def get_dim_name_key
    ret = dim_name_key ? dim_name_key : "dimension.#{id}.name"
    return ret
  end

  def get_dim_desc_key
    ret = dim_desc_key ? dim_desc_key : "dimension.#{id}.desc"
    return ret
  end

  def self.get_dim_type_key(dimCode, tree_type, version)
    return "curriculum.#{tree_type}.#{version}.#{dimCode}"
  end

  def self.get_dim_type_name(dimCode, treeTypeCode, versionCode, localeCode)
    dimCodeKey =  Dimension.get_dim_type_key(dimCode, treeTypeCode, versionCode)
    return Translation.find_translation_name(localeCode, dimCodeKey, nil) ||
      I18n.t("nav_bar.#{dimType.split("_").join("")}.name")
  end

  # To Do: fill this in
  def self.createOrUpdateDimensionRecord()
  end



  ###############################################

  private

  def valid_dim_type
    VAL_DIM_TYPES.include?(dim_type)
  end

end
