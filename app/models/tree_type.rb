class TreeType < BaseRec
  def self.versions_hash()
    ret_hash = Hash.new { |hash, key| hash[key] = [] }
    all.each do |tree_type|
      version_ids = Tree.where(:tree_type_id => tree_type[:id]).pluck('version_id').uniq
      working_version = tree_type[:working_version_id]
      version_ids << working_version if !version_ids.include?(working_version)
      Version.where(:id => version_ids).each do |ver|
        curriculum_code = "#{tree_type.code}.#{ver.code}"
        ret_hash[tree_type.id] << { str: curriculum_code, tree_type_id: tree_type.id, version_id: ver.id }
      end
    end
    ret_hash
  end
end
