class Dimension < BaseRec

  # dim_type field valid options
  BIG_IDEA = 'bigidea'
  MISCONCEPTION = 'miscon'
  QUESTION = 'question'
  CONCEPT = 'concept'
  COMPETENCY = 'comp'
  STANDARD = 'standard'
  VAL_DIM_TYPES = [BIG_IDEA, MISCONCEPTION]

  validate :valid_dim_type

  has_many :dim_trees
  has_many :trees, through: :dim_trees

  # Translation Field
  def get_dim_name_key
    ret = dim_name_key ? dim_name_key : "dimension.#{id}.name"
    return ret
  end

  def get_dim_desc_key
    ret = dim_desc_key ? dim_desc_key : "dimension.#{id}.desc"
    return ret
  end

  ###############################################

  private

  def valid_dim_type
    VAL_DIM_TYPES.include?(dim_type)
  end

end
