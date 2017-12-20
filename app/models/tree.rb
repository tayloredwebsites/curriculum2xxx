class Tree < ApplicationRecord

  # hard coded variables - must match record 1 in database tables - see db/seeds.rb
  OTC_TREE_TYPE_ID = 1
  OTC_TREE_TYPE_CODE = 'OTC'
  OTC_VERSION_ID = 1
  OTC_VERSION_CODE = 'v01'
  OTC_TRANSLATION_START = 'OTC.v01'

  belongs_to :tree_type
  belongs_to :version
  belongs_to :subject
  belongs_to :grade_band
  belongs_to :parent, class_name: "Tree", foreign_key: "parent_id", optional: true

  # are these necessary?
  validates :tree_type, presence: true
  validates :version, presence: true
  validates :subject, presence: true
  validates :grade_band, presence: true

  validates :code, presence: true, allow_blank: false

  # scope for hard coded variables
  scope :otc_tree, -> {
    where(tree_type_id: OTC_TREE_TYPE_ID, version_id: OTC_VERSION_ID)
  }

  # Tree.find_or_add_code_in_tree - find area, component, outcome, or indicator in database
  #   tree_type_id - lookup key
  #   version_id - lookup key
  #   subject_id - lookup key
  #   grade_band_id - lookup key
  #   code - lookup key - area component outcome or indicator code
  #   parent_id - area id for component, component id for outcome, outcome id for indicator
  #   match_code - code to see if looked up before to avoid extra lookups
  #   match_rec - matching record for match code
  def self.find_or_add_code_in_tree(tree_type_id, version_id, subject_id, grade_band_id, code, parent_id, match_code, match_rec)
    if code == match_code
      return match_rec
    else
      matched_codes = Tree.otc_tree.where(subject_id: subject_id, grade_band_id: grade_band_id, code: code)
      if matched_codes.count == 0
        tree = Tree.new
        tree.tree_type_id = tree_type_id
        tree.version_id = version_id
        tree.subject_id = subject_id
        tree.grade_band_id = grade_band_id
        tree.code = code
        tree.parent_id = parent_id
        ret = tree.save
        if !ret
          Rails.logger.error("ERROR: cannot save area: #{area_code}")
        end
        if tree.errors.count > 0
          Rails.logger.error("ERROR: saving area #{area_code} returned errors: #{tree.errors.full_messages}")
          return nil
        else
          return tree
          puts "Added tree item: #{tree.code}"
        end
      elsif matched_codes.count == 1
        return matched_codes.first
      else
        Rails.logger.error("ERROR: Too Many items match in tree: #{@upload.subject_id}, grade_band_id: #{@upload.grade_band_id}, code: #{code}")
        return nil
      end # if
    end # if code == match_code
  end

end
