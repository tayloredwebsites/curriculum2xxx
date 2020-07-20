class Activity < BaseRec
  belongs_to :lesson_plan
  has_many :activity_dimensions
  has_many :dimensions, through: :activity_dimensions
  belongs_to :dimension, optional: true
  has_many :resource_joins, as: :resourceable
  has_many :resources, through: :resource_joins


  LOOKUP_TABLES = ['student_org', 'teach_strat']

  # def self.options_hash_and_transl_keys
  # 	optionsHash = Hash.new { |h, k| h[k] = [] }
  # 	translKeys = []
  # 	LookupTablesOption.where(
  # 		table_name: LOOKUP_TABLES
  # 	).each do |l|
  #     translKeys << l.lookup_translation_key
  # 	  optionsHash[l.table_name] << l
  # 	end
  # 	return [optionsHash, translKeys]
  # end

end