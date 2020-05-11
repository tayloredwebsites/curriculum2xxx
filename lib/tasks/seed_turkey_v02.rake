# seed_turkey.rake
namespace :seed_turkey_v02 do

  task populate: [:create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors]

  ###################################################################################
  desc "create the Curriculum Tree Type and Version - Is Rerunnable!"
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
      # [dim code]_dim_type fields deprecated in favor of dim_codes
      # miscon_dim_type: 'miscon',
      # big_ideas_dim_type: 'bigidea',
      # ess_q_dim_type: 'essq',
      dim_codes: 'essq,bigidea,pract,miscon',
      tree_code_format: 'subject,grade,unit,sub_unit,comp',
      detail_headers: 'grade,unit,(sub_unit),comp,<essq<,>bigidea>,[pract],{explain},[miscon],[sector],[connect],[refs]',
      grid_headers: 'grade,unit,(sub_unit),comp,[essq],[bigidea],[pract],{explain},[miscon]'
    }
    if myTreeType.count < 1
      myTreeType = TreeType.create(myTreeTypeValues)
    else
      myTreeType = TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    tfvs = TreeType.where(code: 'tfv', version_id: @v02.id)
    throw "ERROR: Missing tfv tree type" if tfvs.count < 1
    @tfv = tfvs.first

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'app.title', 'Curriculum App')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.grade', 'Grade')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.unit', 'Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for essential questions as K-12 Big Ideas.'
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.sub_unit', 'Sub-Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for Sub-Unit.'
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.comp', 'Competence')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.set.future.name', 'Future Sectors')
    throw "ERROR updating sector.set.fut.sect.name: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.title', 'Turkey STEM Curriculum')
    throw "ERROR updating curriculum.tfv.title translation: #{message}" if status == BaseRec::REC_ERROR

    # # Titles of Turkish Dimension Pages (see seeds.rb for default english)
    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'trees.bigidea.title', "Büyük Fikirler")
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'trees.miscon.title', "Yanlış")
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

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
    # create an initial admin user to get things going.
    # Note: the Curriculum to display by default is TFV tree type
    # to do - turn off admin flag for production.
    if User.where(email: 'tfv@sample.com').count < 1
      User.create(
        email: 'tfv@sample.com',
        password: 'password',
        password_confirmation: 'password',
        given_name: 'TFV',
        family_name: 'Web App',
        roles: 'admin',
        govt_level: "1",
        govt_level_name: "govt_level_name",
        municipality: "municipality",
        institute_type: "1",
        institute_name_loc: "institute_name_loc",
        position_type: "1",
        subject1: "subject1",
        subject2: "subject2",
        gender: "2",
        education_level: "1",
        work_phone: "work_phone",
        work_address: "work_address",
        terms_accepted: true,
        confirmed_at: DateTime.now,
        last_tree_type_id: @tfv
      )
    end
    @user = User.where(email: 'tfv@sample.com').first
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
  @subjects = []
  task create_subjects: :environment do
    if Subject.where(tree_type_id: @tfv.id, code: 'bio').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'bio',
        base_key: 'subject.tfv.v02.bio'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'che').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'che',
        base_key: 'subject.tfv.v02.che'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'mat').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'mat',
        base_key: 'subject.tfv.v02.mat'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'sci').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'sci',
        base_key: 'subject.tfv.v02.sci'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'phy').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'phy',
        base_key: 'subject.tfv.v02.phy'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'ear').count < 1
      @subjects << Subject.create(
        tree_type_id: @tfv.id,
        code: 'ear',
        base_key: 'subject.tfv.v02.ear'
      )
    end
    # create the technology subject:
    if Subject.where(tree_type_id: @tfv.id, code: 'tech').count < 1
      tech = Subject.create(
        tree_type_id: @tfv.id,
        code: 'tech',
        base_key: 'subject.tfv.v02.tech',
        min_grade: 0,
        max_grade: 12
      )
    end

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.bio.name', 'Biology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.bio.abbr', 'Bio')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.bio.name', 'Biyoloji')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.bio.abbr', 'Biy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.che.name', 'Chemistry')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.che.abbr', 'Chem')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.che.name', 'Kimya')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.che.abbr', 'Kim')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.mat.name', 'Mathematics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.mat.abbr', 'Math')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.mat.name', 'Matematik')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.mat.abbr', 'Mat')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.phy.name', 'Physics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.phy.abbr', 'Phy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.phy.name', 'Fizik')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.phy.abbr', 'Fiz')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.sci.name', 'Science')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.sci.abbr', 'Sci')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.sci.name', 'Bilim')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.sci.abbr', 'Bil')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.ear.name', 'Earth, Space, & Environmental Science')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.v01.ear.abbr', 'Ear')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.ear.name', '
    Dünya, Uzay ve Çevre Bilimi')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.v01.ear.abbr', 'Dün')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(@loc_en.code, 'subject.tfv.v02.tech.name', 'Tech Engineering')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(@loc_en.code, 'subject.tfv.v02.tech.abbr', 'Tech')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(@loc_en.code, 'subject.default.tech.name', 'Tech Engineering')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(@loc_en.code, 'subject.default.tech.abbr', 'tech')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    # # update existing dimension records with subject code
    # # only needed for updating existing data
    # dimensions = Dimension.where(subject_code: "")
  	# dimensions.each do |d|
  	# 	begin
    #     code = Subject.find(d.subject_id).code
    #     d.subject_code = code
    #     d.save!
    #      puts "Saved subject code '#{d.subject_code}' for dimension id: #{d.id}"
  	# 	rescue
    #     puts "Failed to save subject code for dimension id: #{d.id}"
  	# 	end
  	# end

    # Set Subject Abbreviations:
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
      tech: 'Tech Engineering'
    }
    BaseRec::BASE_SUBJECTS.each do |s|
        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_abbr_key(s), "#{s}")
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_name_key(s), "#{s_lookup[:"#{s}"]}")
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        puts "Saved Translations for #{s}, #{s_lookup[:"#{s}"]}"
    end

  end #create_subjects

  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do

    # create upload records for .csv format uploads for V02
    Upload.delete_all

    @subjects = []
    @bio = Subject.where(tree_type_id: @tfv.id, code: 'bio').first
    @bio.min_grade = 9
    @bio.max_grade = 12
    @bio.save
    @che = Subject.where(tree_type_id: @tfv.id, code: 'che').first
    @mat = Subject.where(tree_type_id: @tfv.id, code: 'mat').first
    @sci = Subject.where(tree_type_id: @tfv.id, code: 'sci').first
    @phy = Subject.where(tree_type_id: @tfv.id, code: 'phy').first
    @ear = Subject.where(tree_type_id: @tfv.id, code: 'ear').first
    @tech = Subject.where(tree_type_id: @tfv.id, code: 'tech').first
    @subjects = [@bio, @che, @mat, @sci, @phy, @ear, @tech]

    @loc_tr = Locale.where(code: 'tr').first
    @loc_en = Locale.where(code: 'en').first

    @subjects.each do |s|
      if Upload.where(tree_type_code: 'tfv',
        subject_id: s.id,
        grade_band_id: nil,
        locale_id: @loc_en.id
      ).count < 1
        Upload.create!(
          tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_en.id,
          status: 0,
          filename: "tfvV02#{s.code.capitalize}AllEng.csv"
        )
      end
      if Upload.where(tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_tr.id
        ).count < 1
        Upload.create!(
          tree_type_code: 'tfv',
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_tr.id,
          status: 0,
          filename: "tfvV02#{s.code.capitalize}AllTur.csv"
        )
      end
    end
  end #create_uploads

  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
    # Populate the Sector table and its translations for all  languages
    if Sector.where(sector_set_code: 'future', code: '1').count < 1
      Sector.create(sector_set_code: 'future', code: '1', name_key: 'sector.future.1.name', base_key: 'sector.future.1')
    end
    if Sector.where(sector_set_code: 'future', code: '2').count < 1
      Sector.create(sector_set_code: 'future', code: '2', name_key: 'sector.future.2.name', base_key: 'sector.future.2')
    end
    if Sector.where(sector_set_code: 'future', code: '3').count < 1
      Sector.create(sector_set_code: 'future', code: '3', name_key: 'sector.future.3.name', base_key: 'sector.future.3')
    end
    if Sector.where(sector_set_code: 'future', code: '4').count < 1
      Sector.create(sector_set_code: 'future', code: '4', name_key: 'sector.future.4.name', base_key: 'sector.future.4')
    end
    if Sector.where(sector_set_code: 'future', code: '5').count < 1
      Sector.create(sector_set_code: 'future', code: '5', name_key: 'sector.future.5.name', base_key: 'sector.future.5')
    end
    if Sector.where(sector_set_code: 'future', code: '6').count < 1
      Sector.create(sector_set_code: 'future', code: '6', name_key: 'sector.future.6.name', base_key: 'sector.future.6')
    end
    if Sector.where(sector_set_code: 'future', code: '7').count < 1
      Sector.create(sector_set_code: 'future', code: '7', name_key: 'sector.future.7.name', base_key: 'sector.future.7')
    end
    if Sector.where(sector_set_code: 'future', code: '8').count < 1
      Sector.create(sector_set_code: 'future', code: '8', name_key: 'sector.future.8.name', base_key: 'sector.future.8')
    end
    @sector1 = Sector.where(sector_set_code: 'future', code: '1').first
    @sector2 = Sector.where(sector_set_code: 'future', code: '2').first
    @sector3 = Sector.where(sector_set_code: 'future', code: '3').first
    @sector4 = Sector.where(sector_set_code: 'future', code: '4').first
    @sector5 = Sector.where(sector_set_code: 'future', code: '5').first
    @sector6 = Sector.where(sector_set_code: 'future', code: '6').first
    @sector7 = Sector.where(sector_set_code: 'future', code: '7').first
    @sector8 = Sector.where(sector_set_code: 'future', code: '8').first


    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.1.name', 'Industry 4.0')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.2.name', 'Sensors and Imaging Technology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.3.name', 'New Food Technologies')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.4.name', 'Biomedical Technology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.5.name', 'Nanotechnology / Space Technology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.6.name', 'Global Warming')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.7.name', 'Internet of Objects / 5G')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.future.8.name', 'Population Increase vs Resource Consumption')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.1.name', 'Endüstri 4.0')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.2.name', 'Sensörler ve Görüntüleme Teknolojisi')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.3.name', 'Yeni Gıda Teknolojileri')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.4.name', 'Biyomedikal Teknoloji')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.5.name', 'Nanoteknoloji / Uzay Teknolojisi')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.6.name', 'Küresel Isınma')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.7.name', 'Nesnelerin İnterneti / 5G')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.future.8.name', 'Nüfus artışı karşı Kaynak Tüketimi')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "Sector translations are created for tfv"
  end


  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
  end

end
