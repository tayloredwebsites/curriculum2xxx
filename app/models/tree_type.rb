class TreeType < BaseRec

  def self.get_sector_set_code(code)
    return code.split(",")[0]
  end

  def self.versions_hash()
    ret_hash = Hash.new { |hash, key| hash[key] = [] }
    all.each do |tree_type|
      begin
        ver = Version.find(tree_type[:version_id])
        curriculum_code = "#{tree_type.code}.#{ver.code}"
        ret_hash[tree_type.id] << { str: curriculum_code, tree_type_id: tree_type.id, version_id: ver.id, working: tree_type.working_status }
      rescue StandardError => e
        puts "Could not find version for treeType record: #{tree_type.inspect} Error: #{e.inspect}"
      end
    end
    ret_hash
  end
end
