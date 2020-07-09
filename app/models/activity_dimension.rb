class ActivityDimension < BaseRec
  belongs_to :activity
  belongs_to :dimension
  before_save :copy_dim_code
	private
	  def copy_dim_code
	    self.dim_code = dimension.dim_code
	  end
end