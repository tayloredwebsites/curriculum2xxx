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
      engl: 'English',
      eng: 'Engineering',
      mat: 'Math',
      mec: 'Mechanics',
      phy: 'Physics',
      sci: 'Science',
      ear: 'Earth Science',
      geo: 'Geology',
      stem: 'Science And Engineering Practices',
      spec: 'Specific Practices',
      tech: 'Tech Engineering'
    }

    BaseRec::BASE_SUBJECTS.each do |s|
        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_abbr_key(s), "#{s}")
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_name_key(s), "#{s_lookup[:"#{s}"]}")
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        puts "Saved Translations for #{s}, #{s_lookup[:"#{s}"]}"
    end

    BaseRec::BASE_PRACTICES.each do |p|
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_abbr_key(p), "#{p.upcase}")
        throw "ERROR updating practice translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_name_key(p), "#{s_lookup[:"#{p}"]}")
        throw "ERROR updating practice translation: #{message}" if status == BaseRec::REC_ERROR
        puts "Saved Translations for #{p}, #{s_lookup[:"#{p}"]}"
    end

  end #task set_subject_codes: :environment do


  ###################################################
  desc "Delete all Dimensions, DimTrees, and their associated Translations"
  task destroy_all: :environment do
    dim_trees = DimTree.all
    dims = Dimension.all
    dim_trees.each do |dt|
      if dt.tree
        t = dt.tree.base_key
        d = dt.dimension
        key = DimTree.getDimExplanationKey(t, d.dim_type, d.id)
        puts "Deleting DimTree Translation: #{key}"
        Translation.where(:key => key).delete_all
      else
        puts "Could not delete DimTree Translation because Tree record was missing"
      end
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


  desc "Delete all outcome-level Trees, Outcomes, TreeTrees, SectorTrees, and related Translations"
  task destroy_v02_outcomes: :environment do
    trees = Tree.joins(:outcome).where(:tree_type_id => 2)
    trees.each do |t|
      #delete tree translations
      puts "Deleting Tree: #{t.format_code("en")}"
      puts "Deleting Tree translation"
      Translation.where(:key => t.name_key).delete_all
      if t.outcome
        puts "Deleting Tree outcome"
        Translation.where(:key => t.outcome.get_explain_key).delete_all
        t.outcome.delete
      end #if t.outcome
      #No need to get TreeTrees by both referencer and referencee id,
      #because TreeTree connections across curriculum versions are not
      #possible yet
      puts "Deleting TreeTree connections"
      TreeTree.where(:tree_referencer_id => t.id).each do |tt|
        Translation.where(:key => tt.explanation_key).delete_all
        tt.delete
      end #delete TreeTrees

      puts "Deleting SectorTrees"
      SectorTree.where(:tree_id => t.id).each do |tt|
        Translation.where(:key => tt.explanation_key).delete_all
        tt.delete
      end #delete TreeTrees
      t.delete
      puts "Deleted Tree"
    end
  end #destroy_v02_outcomes

  ###################################################
  desc "Set TreeType::dim_codes string for tfv v01 & v02, and egstemuniv v01. Set Dimension::dim_code from dim_type."
  task update_treetypes: :environment do
    dimensions = Dimension.all
    tfvRecs = TreeType.where(code: "tfv")
    @tfvV01 = tfvRecs.first
    @tfvV02 = tfvRecs.second
    @egstemuniv = TreeType.where(code: "egstemuniv").first

    puts "Updating dim_code field for all dimensions"
    # Set dim_code for all dimensions.
    dimensions.each do |dim|
      dim.dim_code = dim.dim_type if dim[:dim_type] && dim.dim_type != ""
      dim.save
    end


    if @tfvV01
      puts "Set dim_codes string for TreeType rec: #{@tfvV01.id}"
      @v01_code = Version.find(@tfvV01.version_id).code
      @tfvV01.dim_codes = "bigidea,miscon"
      @tfvV01.detail_headers = 'grade,unit,chapt,attain,[explanation],[bigidea],{explain},[miscon],[sector],[connect],[refs]'
      @tfvV01.grid_headers = 'grade,unit,chapt,attain,[bigidea],{explain},[miscon]'
      @tfvV01.save
      ###########################################
      # English translations for dimension codes
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("bigidea", @tfvV01.code, @v01_code),
        'Big Ideas')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for bigidea as Big Ideas.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("miscon", @tfvV01.code, @v01_code),
        'Misconceptions')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for miscon as Misconceptions.'
      ###########################################
      # Turkish translations for dimension codes
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_TR,
        Dimension.get_dim_type_key("bigidea", @tfvV01.code, @v01_code),
        'Büyük Fikirler')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create turkish translation record for bigidea as Büyük Fikirler.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_TR,
        Dimension.get_dim_type_key("miscon", @tfvV01.code, @v01_code),
        'yanılgılar')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create turkish translation record for miscon as yanılgılar.'
    end


    if @tfvV02
      puts "Set dim_codes string for TreeType rec: #{@tfvV02.id}"
      @v02_code = Version.find(@tfvV02.version_id).code
      @tfvV02.dim_codes = "essq,bigidea,pract,miscon"
      @tfvV02.detail_headers = 'grade,unit,(sub_unit),comp,[essq],[bigidea],[pract],{explain},[miscon],[sector],[connect],[refs]'
      @tfvV02.grid_headers ='grade,unit,(sub_unit),comp,[essq],[bigidea],[pract],{explain},[miscon]'
      @tfvV02.save

      ###########################################
      # English translations for dimension codes
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("essq", @tfvV02.code, @v02_code),
        'K-12 Big Ideas')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for essq as K-12 Big Ideas.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("bigidea", @tfvV02.code, @v02_code),
        'Specific Big Ideas')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for bigidea as Specific Big Ideas.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("pract", @tfvV02.code, @v02_code),
        'Associated Practices')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for pract as Associated Practices.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("miscon", @tfvV02.code, @v02_code),
        'Misconceptions')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for miscon as Misconceptions.'
      ###########################################
      # Turkish translations for dimension codes
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_TR,
        Dimension.get_dim_type_key("essq", @tfvV02.code, @v02_code),
        'K-12 Büyük Fikirler')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for essq as K-12 Büyük Fikirler.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_TR,
        Dimension.get_dim_type_key("bigidea", @tfvV02.code, @v02_code),
        'Belirli Büyük Fikirler')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create turkish translation record for bigidea as Belirli Büyük Fikirler.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_TR,
        Dimension.get_dim_type_key("pract", @tfvV02.code, @v02_code),
        'İlişkili Uygulamalar')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for pract as İlişkili Uygulamalar.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_TR,
        Dimension.get_dim_type_key("miscon", @tfvV02.code, @v02_code),
        'yanılgılar')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create turkish translation record for miscon as yanılgılar.'
    end


    if @egstemuniv
      puts "Set dim_codes string for TreeType rec: #{@egstemuniv.id}"
      @eg_v01_code = Version.find(@egstemuniv.version_id).code
      @egstemuniv.dim_codes = "bigidea,miscon"
      @egstemuniv.detail_headers = 'grade,sem,unit,lo,indicator,[bigidea],{explain},[miscon],[sector],[connect],[refs]'
      @egstemuniv.grid_headers = 'grade,sem,unit,lo,indicator,[bigidea],{explain},[miscon]'
      @egstemuniv.save

      ###########################################
      # English translations for dimension codes
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("bigidea", @egstemuniv.code, @eg_v01_code),
        'Big Ideas')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for bigidea as Big Ideas.'
      rec, status, message = Translation.find_or_update_translation(
        BaseRec::LOCALE_EN,
        Dimension.get_dim_type_key("miscon", @egstemuniv.code, @eg_v01_code),
        'Misconceptions')
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      STDOUT.puts 'Create translation record for miscon as Misconceptions.'
    end

  end #task update_treetypes: :environment do

end