class Tree < ApplicationRecord


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
  scope :otc_listing, -> {
    order('subjects.code', 'grade_bands.code', 'locales.name')
    # where(active: true)
  }

  # Tree.find_or_add_code_in_tree
  # - get hierarchy item, and add if necessary
  #   tree_type_id - lookup key
  #   version_id - lookup key
  #   subject_id - lookup key
  #   grade_band_id - lookup key
  #   code - lookup key - area, component, outcome, or indicator code
  #   parent_rec - parent (area for component, component for outcome, outcome for indicator)
  #   match_rec - last record uploaded to see if matches record from prior row.
  def self.find_or_add_code_in_tree(tree_type_id, version_id, subject_id, grade_band_id, code, parent_rec, match_rec)
    match_code = (match_rec ? match_rec.code : '')

    # code field in database is of this format:  <area code>[.<component code>[.<outcome code>[.<indicator code>]]]
    # since spreadsheet only includes the code at the current level, we must build the full code before saving it
    parent_code_prepend = parent_rec.present? ? parent_rec.code + '.' : ''
    new_code = parent_code_prepend + code

    if code == match_code
      return new_code, match_rec, ApplicationRecord::SAVE_STATUS_SKIP, "#{new_code}"
    else
      # get the tree records for this hierarchy item
      matched_codes = Tree.otc_tree.where(subject_id: subject_id, grade_band_id: grade_band_id, code: new_code)
      if matched_codes.count == 0
        # It has not been uploaded yet.  create it.
        tree = Tree.new
        tree.tree_type_id = tree_type_id
        tree.version_id = version_id
        tree.subject_id = subject_id
        tree.grade_band_id = grade_band_id
        tree.code = new_code
        tree.parent_id = parent_rec.present? ? parent_rec.id : nil
        ret = tree.save
        # if !ret
        #   Rails.logger.error("ERROR: cannot save hierarchy item: #{code}")
        # end
        if tree.errors.count > 0
          Rails.logger.error("ERROR: saving hierarchy item: #{new_code} returned errors: #{tree.errors.full_messages}")
          return new_code, nil, ApplicationRecord::SAVE_STATUS_ERROR, tree.errors.full_messages
        else
          return new_code, tree, ApplicationRecord::SAVE_STATUS_ADDED, "#{new_code}"
        end
      elsif matched_codes.count == 1
        # it already exists, skip
        return new_code, matched_codes.first, ApplicationRecord::SAVE_STATUS_NO_CHANGE, "#{new_code}"
      else
        # too many matching items in database: system error.
        err_str = "Too Many items match in tree: #{@upload.subject_id}, grade_band_id: #{@upload.grade_band_id}, code: #{new_code}"
        Rails.logger.error("ERROR: #{err_str} ")
        return new_code, nil, ApplicationRecord::SAVE_STATUS_ERROR, err_str
      end # if
    end # if code == match_code
  end

end
