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

  private

  def valid_dim_type
    VAL_DIM_TYPES.include?(dim_type)
  end

end
