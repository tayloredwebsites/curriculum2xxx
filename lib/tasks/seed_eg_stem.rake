# seed_eg_stem.rake
namespace :seed_eg_stem do

  task populate: [:create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors]


  ###################################################################################
  # set up Curriculum Tree Type and Version

  desc "create the tree type(s)"
  task create_tree_type: :environment do

    # reference version record from seeds.rb
    @v01 = Version.where(code: 'v01').first
    throw "Missing version record" if !@v01

    # create Tree Type record for the Curriculum
    myTreeType = TreeType.where(code: 'egstemuniv')
    myTreeTypeValues = {
      code: 'egstemuniv',
      hierarchy_codes: 'grade,sem,unit,lo,indicator',
      valid_locales: BaseRec::LOCALE_EN,
      sector_set_code: 'gr_chall',
      sector_set_name_key: 'sector.set.gr.chal.name',
      curriculum_title_key: 'curriculum.egstemuniv.title', #'Egypt STEM Teacher Prep Curriculum'
      outcome_depth: 3,
      version_id: @v01.id,
      working_status: true,
      miscon_dim_type: 'miscon',
      big_ideas_dim_type: 'bigidea',
      ess_q_dim_type: 'essq',
      tree_code_format: 'grade,unit,lo',
      detail_headers: 'grade,sem,unit,lo,indicator,[subj_big_idea],[ess_q],{explain},[miscon],[sector],[connect],[refs]',
      grid_headers: 'grade,unit,(sub_unit),comp,[subj_big_idea],[ess_q],explain,[miscon],[connect],[refs]'
    }
    if myTreeType.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'egstemuniv').count != 1
    @egstem = TreeType.where(code: 'egstemuniv').first

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.grade', 'Grade')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.sem', 'Semester')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.unit', 'Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.lo', 'Learning Outcome')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.indicator', 'Indicator')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.set.gr.chal.name', 'Grand Challenges')
    throw "ERROR updating curriculum.egstemuniv.title translation: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.title', 'Egypt STEM Teacher Prep Curriculum')
    throw "ERROR updating curriculum.egstemuniv.title translation: #{message}" if status == BaseRec::REC_ERROR

    puts "Curriculum (Tree Type) is created for egstemuniv "
    puts "  Created Curriculum: #{@egstem.code} with Hierarchy: #{@egstem.hierarchy_codes}"
  end #create_tree_type


  ###################################################################################
  desc "load up the locales (created in seeds.rb seed file)"
  task load_locales: :environment do
    @loc_tr = Locale.first
    @loc_en = Locale.second
    @loc_ar_EG = Locale.third
    puts "Locales: #{@loc_en.code}: #{@loc_en.name}, #{@loc_tr.code}: #{@loc_tr.name}, #{@loc_ar_EG.code}: #{@loc_ar_EG.name}"
  end #load_locales


  ###################################################################################
  desc "create the admin user(s)"
  task create_admin_user: :environment do
    # create an initial admin user to get things going.
    # Note: the Curriculum to display by default is EGSTEM tree type
    # to do - turn off admin flag for production.
    if User.where(email: 'egstemuniv@sample.com').count < 1
      User.create(
        email: 'egstemuniv@sample.com',
        password: 'password',
        password_confirmation: 'password',
        given_name: 'Admin of',
        family_name: 'Curriculum App',
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
        last_tree_type_id: @egstem
      )
    end
    @user = User.where(email: 'egstemuniv@sample.com').first
    puts "admin user is created for egstemuniv"
  end #create_admin_user


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    sort_counter = 0
    %w(fresh soph junior senior).each do |g|
      begin
        gf = (g == 'k') ? 0 : sort_counter
        if GradeBand.where(tree_type_id: @egstem.id, code: g).count < 1
          GradeBand.create(
            tree_type_id: @egstem.id,
            code: g,
            sort_order: gf
          )
        end
        sort_counter += 1
      rescue => ex
        puts("exception creating gradeband #{g}, error: #{ex}")
      end
    end

    @gb_fresh = GradeBand.where(tree_type_id: @egstem.id, code: 'fresh').first
    @gb_soph = GradeBand.where(tree_type_id: @egstem.id, code: 'soph').first
    @gb_junior = GradeBand.where(tree_type_id: @egstem.id, code: 'junior').first
    @gb_senior = GradeBand.where(tree_type_id: @egstem.id, code: 'senior').first
    @gb_univ = [@gb_fresh, @gb_soph, @gb_junior, @gb_senior]
    puts "grade bands are created for EGSTEM"

    # put in translations for Grade Names
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.egstemuniv.fresh.name', 'Freshman')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.egstemuniv.soph.name', 'Sophmore')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.egstemuniv.junior.name', 'Junior')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.egstemuniv.senior.name', 'Senior')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    @subjects = []
    if Subject.where(tree_type_id: @egstem.id, code: 'bio').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'bio',
        base_key: 'subject.egstemuniv.v01.bio'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'cap').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'cap',
        base_key: 'subject.egstemuniv.v01.cap'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'che').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'che',
        base_key: 'subject.egstemuniv.v01.che'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'engl').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'engl',
        base_key: 'subject.egstemuniv.v01.engl'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'edu').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'edu',
        base_key: 'subject.egstemuniv.v01.edu'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'geo').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'geo',
        base_key: 'subject.egstemuniv.v01.geo'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'mat').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'mat',
        base_key: 'subject.egstemuniv.v01.mat'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'mec').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'mec',
        base_key: 'subject.egstemuniv.v01.mec'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'phy').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'phy',
        base_key: 'subject.egstemuniv.v01.phy'
      )
    end
    puts "Subjects are created for EGSTEM"

    #bio
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.bio.name', 'Biology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.bio.abbr', 'Bio')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #cap
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.cap.name', 'Capstones')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.cap.abbr', 'Cap')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #che
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.che.name', 'Chemistry')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.che.abbr', 'Chem')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #engl
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.engl.name', 'English')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.engl.abbr', 'Engl')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #edu
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.edu.name', 'Education')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.edu.abbr', 'Edu')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #geo
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.geo.name', 'Geology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.geo.abbr', 'Geo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #mat
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mat.name', 'Mathematics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mat.abbr', 'Math')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #mec
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mec.name', 'Mechanics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mec.abbr', 'Mec')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #phy
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.phy.name', 'Physics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.phy.abbr', 'Phy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "subject translations are created for EGSTEM"
  end #create_subjects


  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do
    # code here
    # puts "Try to create uploads."
    @gb_univ.each do |g|
      @subjects.each do |s|
        if Upload.where(
          tree_type_code: @egstem.code,
          subject_id: s.id,
          grade_band_id: g.id,
          locale_id: @loc_en.id
        ).count < 1
          # puts "Try to create uploads for grade #{g} subject #{s}"
          Upload.create(
            tree_type_code: @egstem.code,
            subject_id: s.id,
            grade_band_id: g.id,
            locale_id: @loc_en.id,
            status: 0,
            filename: "#{@egstem.code}#{s.code.capitalize}#{g.code.capitalize}Eng.txt"
          )
        end
      end
    end
  end #create_uploads


  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
    if Sector.where(sector_set_code: 'gr_chall', code: '1').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '1', name_key: 'sector.egstemuniv.1.name', base_key: 'sector.egstemuniv.1')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '2').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '2', name_key: 'sector.egstemuniv.2.name', base_key: 'sector.egstemuniv.2')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '3').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '3', name_key: 'sector.egstemuniv.3.name', base_key: 'sector.egstemuniv.3')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '4').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '4', name_key: 'sector.egstemuniv.4.name', base_key: 'sector.egstemuniv.4')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '5').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '5', name_key: 'sector.egstemuniv.5.name', base_key: 'sector.egstemuniv.5')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '6').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '6', name_key: 'sector.egstemuniv.6.name', base_key: 'sector.egstemuniv.6')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '7').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '7', name_key: 'sector.egstemuniv.7.name', base_key: 'sector.egstemuniv.7')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '8').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '8', name_key: 'sector.egstemuniv.8.name', base_key: 'sector.egstemuniv.8')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '9').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '9', name_key: 'sector.egstemuniv.9.name', base_key: 'sector.egstemuniv.9')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '10').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '10', name_key: 'sector.egstemuniv.10.name', base_key: 'sector.egstemuniv.10')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '11').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '11', name_key: 'sector.egstemuniv.11.name', base_key: 'sector.egstemuniv.11')
    end
    puts "Sectors are created for EGSTEM"

    @sector1 = Sector.where(sector_set_code: 'gr_chall', code: '1').first
    @sector2 = Sector.where(sector_set_code: 'gr_chall', code: '2').first
    @sector3 = Sector.where(sector_set_code: 'gr_chall', code: '3').first
    @sector4 = Sector.where(sector_set_code: 'gr_chall', code: '4').first
    @sector5 = Sector.where(sector_set_code: 'gr_chall', code: '5').first
    @sector6 = Sector.where(sector_set_code: 'gr_chall', code: '6').first
    @sector7 = Sector.where(sector_set_code: 'gr_chall', code: '7').first
    @sector8 = Sector.where(sector_set_code: 'gr_chall', code: '8').first
    @sector9 = Sector.where(sector_set_code: 'gr_chall', code: '9').first
    @sector10 = Sector.where(sector_set_code: 'gr_chall', code: '10').first
    @sector11 = Sector.where(sector_set_code: 'gr_chall', code: '11').first


    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.1.name', 'Deal with population growth and its consequences.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.2.name', 'Improve the use of alternative energies.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.3.name', 'Deal with urban congestion and its consequences.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.4.name', 'Improve the scientific and technological environment for all.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.5.name', 'Work to eradicate public health issues/disease.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.6.name', 'Improve uses of arid areas.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.7.name', 'Manage and increase the sources of clean water.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.8.name', 'Increase the industrial and agricultural bases of Egypt.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.9.name', 'Address and reduce pollution fouling our air, water and soil.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.10.name', 'Recycle garbage and waste for economic and environmental purposes.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstemuniv.11.name', 'Reduce and adapt to the effect of climate change.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "Sector translations are created for EGSTEM"
  end #create_sectors

end
