namespace :dimensions do
  desc "set the subject_code field for Dimensions (if not already set), from the subject_id"
  task set_subject_codes: :environment do

  	dimensions = Dimension.where(subject_code: "")
  	dimensions.each do |d|
  		begin
        code = Subject.find(d.subject_id).code
        d.subject_code = code
        d.save!
         puts "Saved subject code '#{d.subject_code}' for dimension id: #{d.id}"
  		rescue
        puts "Failed to save subject code for dimension id: #{d.id}"
  		end
  	end

    s_lookup = {
      bio: 'Biology',
      cap: 'Capstones',
      che: 'Chemistry',
      edu: 'Education',
      eng: 'English',
      mat: 'Math',
      mec: 'Mechanics',
      phy: 'Physics',
      sci: 'Science',
      ear: 'Earth Science',
      geo: 'Geology'
    }
    BaseRec::BASE_SUBJECTS.each do |s|
        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.base.#{s}.abbr", "#{s}")
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.base.#{s}.name", "#{s_lookup[:"#{s}"]}")
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        puts "Saved Translations for #{s}, #{s_lookup[:"#{s}"]}"
    end

  end #task set_subject_codes: :environment do


  desc "Delete all Dimensions, DimTrees, and their associated Translations"
  task destroy_all: :environment do
    dim_trees = DimTree.all
    dims = Dimension.all
    dim_trees.each do |dt|
      t = dt.tree.base_key
      d = dt.dimension
      key = DimTree.getDimExplanationKey(t, d.dim_type, d.id)
      puts "Deleting DimTree Translation: #{key}"
      Translation.where(:key => key).delete_all
    end
    dims.each do |d|
      puts "Deleting Dim Name Translation: #{d.get_dim_name_key}"
      Translation.where(:key => d.get_dim_name_key).delete_all
      puts "Deleting Dim Desc Translation: #{d.get_dim_desc_key}"
      Translation.where(:key => d.get_dim_desc_key).delete_all
    end
     puts "Deleting all DimTree records"
     dim_trees.delete_all
     puts "Deleting all Dimension records"
     dims.delete_all
  end # task destroy_all

end