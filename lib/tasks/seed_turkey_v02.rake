# seed_turkey.rake
namespace :seed_turkey_v02 do

  task populate: [:create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors]

  ###################################################################################
  desc "create the Curriculum Tree Type and Version"
  task create_tree_type: :environment do

    # reference version record from seeds.rb
    myVersion = Version.where(:code => 'v02')
    if myVersion.count > 0
      @v02 = myVersion.first
    else
      @v02 = Version.new
      @v02.code = 'v02'
      @v02.save
      @v02.reload
    end

    # create Tree Type record for the Curriculum
    myTreeType = TreeType.where(code: 'tfv', version_id: @v02.id)
    myTreeTypeValues = {
      code: 'tfv',
      hierarchy_codes: 'grade,unit,sub_unit,comp',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_TR,
      sector_set_code: 'future,hide',
      sector_set_name_key: 'sector.set.future.name',
      curriculum_title_key: 'curriculum.tfv.title', # 'Turkey STEM Curriculum'
      outcome_depth: 3,
      version_id: @v02.id,
      working_status: true,
      miscon_dim_type: 'miscon',
      big_ideas_dim_type: 'bigidea',
      ess_q_dim_type: 'essq',
      tree_code_format: 'grade,unit,sub_unit,comp',
      detail_headers: 'grade,unit,(sub_unit),comp,[subj_big_idea],[ess_q],{explain},[miscon],[sector],[connect],[refs]',
      grid_headers: 'grade,unit,(sub_unit),comp,[subj_big_idea],[ess_q],explain,[miscon],[connect],[refs]'
    }
    if myTreeType.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'tfv').count != 2
    @tfv = TreeType.where(code: 'tfv', version_id: @v02.id).first

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Dimension.get_dim_type_key(myTreeType.ess_q_dim_type, myTreeType.code, @v02.code), 'K-12 Big Idea')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for essential questions as K-12 Big Ideas.'

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.comp', 'Competency')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.sub_unit', 'Sub-Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for Sub-Unit.'

    puts "Curriculum (Tree Type) is created for tfv "
    puts "  Created Curriculum: #{@tfv.code} with Hierarchy: #{@tfv.hierarchy_codes}"
  end #create_tree_type


  ###################################################################################
  desc "load up the locales (created in seeds.rb seed file)"
  task load_locales: :environment do
    @loc_tr = Locale.where(code: 'tr').first
    @loc_en = Locale.where(code: 'en').first
    @loc_ar_EG = Locale.where(code: 'ar_EG').first
    puts "Locales: #{@loc_en.code}: #{@loc_en.name}, #{@loc_tr.code}: #{@loc_tr.name}, #{@loc_ar_EG.code}: #{@loc_ar_EG.name}"
  end #load_locales


  ###################################################################################
  desc "create the admin user(s)"
  task create_admin_user: :environment do
  end #create_admin_user


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    sort_counter = 0
    %w(k 1 2 3 4 5 6 7 8 9 10 11 12).each do |g|
      begin
        gf = (g == 'k') ? 0 : sort_counter
        if GradeBand.where(tree_type_id: @tfv.id, code: g).count < 1
          GradeBand.create(
            tree_type_id: @tfv.id,
            code: g,
            sort_order: gf
          )
        end
        sort_counter += 1
      rescue => ex
        puts("exception creating gradeband #{g}, error: #{ex}")
      end
    end
    @gb_k = GradeBand.where(tree_type_id: @tfv.id, code: 'k').first
    @gb_1 = GradeBand.where(tree_type_id: @tfv.id, code: '1').first
    @gb_2 = GradeBand.where(tree_type_id: @tfv.id, code: '2').first
    @gb_3 = GradeBand.where(tree_type_id: @tfv.id, code: '3').first
    @gb_4 = GradeBand.where(tree_type_id: @tfv.id, code: '4').first
    @gb_5 = GradeBand.where(tree_type_id: @tfv.id, code: '5').first
    @gb_6 = GradeBand.where(tree_type_id: @tfv.id, code: '6').first
    @gb_7 = GradeBand.where(tree_type_id: @tfv.id, code: '7').first
    @gb_8 = GradeBand.where(tree_type_id: @tfv.id, code: '8').first
    @gb_9 = GradeBand.where(tree_type_id: @tfv.id, code: '9').first
    @gb_10 = GradeBand.where(tree_type_id: @tfv.id, code: '10').first
    @gb_11 = GradeBand.where(tree_type_id: @tfv.id, code: '11').first
    @gb_12 = GradeBand.where(tree_type_id: @tfv.id, code: '12').first
    @gb_others = [@gb_9, @gb_10, @gb_11, @gb_12]
    @gb_math = [@gb_1, @gb_2, @gb_3, @gb_4, @gb_5, @gb_6, @gb_7, @gb_8, @gb_9, @gb_10, @gb_11, @gb_12]
    @gb_sci = [@gb_3, @gb_4, @gb_5, @gb_6, @gb_7, @gb_8]
    puts "grade bands are created for tfv"
    # put in translations for Grade Names
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.tfv.k.name', 'Kindergarten')
    throw "ERROR creating kindergarten translation: #{message}" if status == BaseRec::REC_ERROR
    [1..12].each do |g|
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "grades.tfv.#{g}.name", "Grade #{g}")
      throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    @subjects = []
    if Subject.where(tree_type_id: @tfv.id, code: 'bio').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'bio',
        base_key: 'subject.tfv.bio'
      )
    end
    @bio = Subject.where(tree_type_id: @tfv.id, code: 'bio').first
    if Subject.where(tree_type_id: @tfv.id, code: 'che').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'che',
        base_key: 'subject.tfv.che'
      )
    end
    @che = Subject.where(tree_type_id: @tfv.id, code: 'che').first
    if Subject.where(tree_type_id: @tfv.id, code: 'mat').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'mat',
        base_key: 'subject.tfv.mat'
      )
    end
    @mat = Subject.where(tree_type_id: @tfv.id, code: 'mat').first
    if Subject.where(tree_type_id: @tfv.id, code: 'sci').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'sci',
        base_key: 'subject.tfv.sci'
      )
    end
    @sci = Subject.where(tree_type_id: @tfv.id, code: 'sci').first
    if Subject.where(tree_type_id: @tfv.id, code: 'phy').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'phy',
        base_key: 'subject.tfv.phy'
      )
    end
    @phy = Subject.where(tree_type_id: @tfv.id, code: 'phy').first
    if Subject.where(tree_type_id: @tfv.id, code: 'ear').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'ear',
        base_key: 'subject.tfv.ear'
      )
    end
    @ear = Subject.where(tree_type_id: @tfv.id, code: 'ear').first
    @subj_others = [@bio, @che, @mat, @phy, @ear]
    @subj_math = [@mat]
    @subj_sci = [@sci]

  end #create_subjects


  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do
    @gb_math.each do |g|
      @subj_math.each do |s|
        if Upload.where(tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: g.id,
          locale_id: @loc_en.id
        ).count < 1
          Upload.create(
            tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_en.id,
            status: 0,
            filename: "tfvV02#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if Upload.where(tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: g.id,
          locale_id: @loc_tr.id
        ).count < 1
          Upload.create(
            tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_tr.id,
            status: 0,
            filename: "tfvV02#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
    @gb_sci.each do |g|
      @subj_sci.each do |s|
        if Upload.where(tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: g.id,
          locale_id: @loc_en.id
        ).count < 1
          Upload.create(
            tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_en.id,
            status: 0,
            filename: "tfvV02#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if Upload.where(tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_tr.id
          ).count < 1
            Upload.create(
            tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_tr.id,
            status: 0,
            filename: "tfvV02#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
    @gb_others.each do |g|
      @subj_others.each do |s|
        if Upload.where(tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: g.id,
          locale_id: @loc_en.id
        ).count < 1
          Upload.create(
            tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_en.id,
            status: 0,
            filename: "tfvV02#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if Upload.where(tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_tr.id
          ).count < 1
          Upload.create(
            tree_type_code: 'tfv',
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_tr.id,
            status: 0,
            filename: "tfvV02#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
  end #create_uploads


  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
  end

end
