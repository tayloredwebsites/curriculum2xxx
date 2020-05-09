# seed_turkey.rake
namespace :seed_stessa_2 do

  task populate: [:create_tree_type, :load_locales, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors, :dimension_translations, :ensure_default_translations]

  ###################################################################################
  desc "create the Curriculum Tree Type and Version for STEM Egypt High School Curriculum"
  task create_tree_type: :environment do

    # reference version record from seeds.rb
    @v01 = Version.where(code: 'v01').first
    throw "Missing version record" if !@v01

    # create Tree Type record for the Curriculum
    myTreeType = TreeType.where(code: 'egstem')
    myTreeTypeValues = {
      code: 'egstem',
      hierarchy_codes: 'grade,sem,unit,lo',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_AR_EG,
      sector_set_code: 'gr_chall',
      sector_set_name_key: 'sector.set.gr_chal.name',
      curriculum_title_key: 'curriculum.egstem.title', # 'Egypt STEM Curriculum'
      outcome_depth: 3,
      version_id: @v01.id,
      working_status: true,
      dim_codes: 'bigidea,essq,concept,skill,miscon',
      tree_code_format: 'subject,grade,lo',
      #To Do: if detail has a ref translation, list as <detail>
      #e.g., <miscon> means one row with two cols: miscon | miscon ref translation
      # for dimension translation use dim.get_dim_ref_key
      detail_headers: 'grade,unit,lo,<bigidea<,>essq>,<concept<,>skill>,[miscon],[sector],[connect],[refs]',
      grid_headers: 'grade,unit,lo,[bigidea],[essq],[concept],[skill],[miscon]'

    }
    if myTreeType.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'egstem').count != 1
    @egstem = TreeType.where(code: 'egstem').first

    # Create ENGLISH translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @egstem.hierarchy_name_key('grade'), 'Grade')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @egstem.hierarchy_name_key('sem'), 'Semester')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @egstem.hierarchy_name_key('unit'), 'Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @egstem.hierarchy_name_key('lo'), 'Learning Outcome')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR


    # Enter ENGLISH translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @egstem.sector_set_name_key, 'Grand Challenges')
    throw "ERROR updating #{@egstem.sector_set_name_key}: #{message}" if status == BaseRec::REC_ERROR

    # Enter ENGLISH translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @egstem.title_key, 'Egypt STEM Curriculum')
    throw "ERROR updating curriculum.egstem.title translation: #{message}" if status == BaseRec::REC_ERROR

    # Create ARABIC translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @egstem.hierarchy_name_key('grade'), 'درجة')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @egstem.hierarchy_name_key('sem'), 'نصف السنة')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @egstem.hierarchy_name_key('unit'), 'وحدة')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @egstem.hierarchy_name_key('lo'), 'نتائج التعلم')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR


    # Enter ARABIC translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @egstem.sector_set_name_key, 'التحديات الكبرى')
    throw "ERROR updating #{@egstem.sector_set_name_key}: #{message}" if status == BaseRec::REC_ERROR

    # Enter ARABIC translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @egstem.title_key, 'منهاج مصر للعلوم والتكنولوجيا والهندسة والرياضيات')
    throw "ERROR updating curriculum.egstem.title translation: #{message}" if status == BaseRec::REC_ERROR


    puts "Curriculum (Tree Type) is created for egstem (high school)"
    puts "  Created Curriculum: #{@egstem.code} with Hierarchy: #{@egstem.hierarchy_codes}"
  end #create_tree_type


  ###################################################################################
  desc "load up the locales (created in seeds.rb seed file)"
  task load_locales: :environment do
    @loc_en = Locale.second
    @loc_ar_EG = Locale.third
    puts "Locales: #{@loc_en.code}: #{@loc_en.name}, #{@loc_ar_EG.code}: #{@loc_ar_EG.name}"
  end #load_locales


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    sort_counter = 0
    %w(1 2 3).each do |g|
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
    puts "grade bands are created for egstem"
    # put in translations for Grade Names
    [1..3].each do |g|
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, GradeBand.build_name_key(@egstem.code, "#{g}"), "Grade #{g}")
      throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, GradeBand.build_name_key(@egstem.code, "#{g}"), "#{g} الصف")
      throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    @subjects = []
    if Subject.where(tree_type_id: @egstem.id, code: 'cap').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'cap',
        base_key: 'subject.egstem.v01.cap'
      )
    end
    @cap = Subject.where(tree_type_id: @egstem.id, code: 'cap').first
    if Subject.where(tree_type_id: @egstem.id, code: 'bio').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'bio',
        base_key: 'subject.egstem.v01.bio'
      )
    end
    @bio = Subject.where(tree_type_id: @egstem.id, code: 'bio').first
    if Subject.where(tree_type_id: @egstem.id, code: 'che').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'che',
        base_key: 'subject.egstem.v01.che'
      )
    end
    @che = Subject.where(tree_type_id: @egstem.id, code: 'che').first
    if Subject.where(tree_type_id: @egstem.id, code: 'mat').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'mat',
        base_key: 'subject.egstem.v01.mat'
      )
    end
    @mat = Subject.where(tree_type_id: @egstem.id, code: 'mat').first
    if Subject.where(tree_type_id: @egstem.id, code: 'phy').count < 1
      @subjects << Subject.create(
        tree_type_id: @egstem.id,
        code: 'phy',
        base_key: 'subject.egstem.v01.phy'
      )
    end
    @phy = Subject.where(tree_type_id: @egstem.id, code: 'phy').first

    @subjs = [@cap, @bio, @che, @mat, @phy]

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @cap.get_versioned_name_key, 'Capstone')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @cap.get_versioned_abbr_key, 'Cap')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @cap.get_versioned_name_key, 'كابستون')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @cap.get_versioned_abbr_key, 'كابستون')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @bio.get_versioned_name_key, 'Biology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @bio.get_versioned_abbr_key, 'Bio')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @bio.get_versioned_name_key, 'مادة الاحياء')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @bio.get_versioned_abbr_key, 'مادة الاحياء')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @che.get_versioned_name_key, 'Chemistry')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @che.get_versioned_abbr_key, 'Chem')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @che.get_versioned_name_key, 'كيمياء')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @che.get_versioned_abbr_key, 'كيمياء')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @mat.get_versioned_name_key, 'Mathematics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @mat.get_versioned_abbr_key, 'Math')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @mat.get_versioned_name_key, 'الرياضيات')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @mat.get_versioned_abbr_key, 'الرياضيات')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @phy.get_versioned_name_key, 'Physics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @phy.get_versioned_abbr_key, 'Phy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @phy.get_versioned_name_key, 'الفيزياء')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @phy.get_versioned_abbr_key, 'الفيزياء')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

  end #create_subjects


  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do
    @subjs.each do |s|
      if Upload.where(tree_type_code: @egstem.code,
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_en.id
      ).count < 1
        Upload.create(
          tree_type_code: @egstem.code,
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_en.id,
          status: 0,
          filename: "egstemV01#{s.code.capitalize}AllEng.txt"
        )
      end
      if Upload.where(tree_type_code: @egstem.code,
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_ar_EG.id
      ).count < 1
        Upload.create(
          tree_type_code: @egstem.code,
          subject_id: s.id,
          grade_band_id: nil,
          locale_id: @loc_ar_EG.id,
          status: 0,
          filename: "egstemV01#{s.code.capitalize}AllAra.txt"
        )
      end
    end # @subjs.each do |s|

  end #create_uploads


  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
    # Populate the Sector table and its translations for all  languages
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '1').count < 1
    Sector.create(sector_set_code: @egstem.sector_set_code, code: '1', name_key: 'sector.gr_chall.1.name', base_key: 'sector.gr_chall.1')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '2').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '2', name_key: 'sector.gr_chall.2.name', base_key: 'sector.gr_chall.2')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '3').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '3', name_key: 'sector.gr_chall.3.name', base_key: 'sector.gr_chall.3')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '4').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '4', name_key: 'sector.gr_chall.4.name', base_key: 'sector.gr_chall.4')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '5').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '5', name_key: 'sector.gr_chall.5.name', base_key: 'sector.gr_chall.5')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '6').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '6', name_key: 'sector.gr_chall.6.name', base_key: 'sector.gr_chall.6')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '7').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '7', name_key: 'sector.gr_chall.7.name', base_key: 'sector.gr_chall.7')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '8').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '8', name_key: 'sector.gr_chall.8.name', base_key: 'sector.gr_chall.8')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '9').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '9', name_key: 'sector.gr_chall.9.name', base_key: 'sector.gr_chall.9')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '10').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '10', name_key: 'sector.gr_chall.10.name', base_key: 'sector.gr_chall.10')
    end
    if Sector.where(sector_set_code: @egstem.sector_set_code, code: '11').count < 1
      Sector.create(sector_set_code: @egstem.sector_set_code, code: '11', name_key: 'sector.gr_chall.11.name', base_key: 'sector.gr_chall.11')
    end
    puts "Sectors are created for EGSTEM"

    @sector1 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '1').first
    @sector2 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '2').first
    @sector3 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '3').first
    @sector4 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '4').first
    @sector5 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '5').first
    @sector6 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '6').first
    @sector7 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '7').first
    @sector8 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '8').first
    @sector9 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '9').first
    @sector10 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '10').first
    @sector11 = Sector.where(sector_set_code: @egstem.sector_set_code, code: '11').first

    # English Translations of Grand Challenges
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector1.get_name_key, 'Deal with population growth and its consequences.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector2.get_name_key, 'Improve the use of alternative energies.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector3.get_name_key, 'Deal with urban congestion and its consequences.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector4.get_name_key, 'Improve the scientific and technological environment for all.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector5.get_name_key, 'Work to eradicate public health issues/disease.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector6.get_name_key, 'Improve uses of arid areas.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector7.get_name_key, 'Manage and increase the sources of clean water.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector8.get_name_key, 'Increase the industrial and agricultural bases of Egypt.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector9.get_name_key, 'Address and reduce pollution fouling our air, water and soil.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector10.get_name_key, 'Recycle garbage and waste for economic and environmental purposes.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @sector11.get_name_key, 'Reduce and adapt to the effect of climate change.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    # Arabic Translations of Grand Challenges
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector1.get_name_key, 'التعامل مع النمو السكاني وعواقبه.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector2.get_name_key, 'تحسين استخدام الطاقات البديلة.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector3.get_name_key, 'التعامل مع الازدحام الحضري وعواقبه.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector4.get_name_key, 'تحسين البيئة العلمية والتكنولوجية للجميع.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector5.get_name_key, 'العمل على القضاء على قضايا / أمراض الصحة العامة.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector6.get_name_key, 'تحسين استخدامات المناطق الجافة.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector7.get_name_key, 'إدارة وزيادة مصادر المياه النظيفة.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector8.get_name_key, 'زيادة القواعد الصناعية والزراعية لمصر.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector9.get_name_key, 'معالجة وتقليل التلوث الناتج عن الهواء والماء والتربة.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector10.get_name_key, 'إعادة تدوير القمامة والنفايات للأغراض الاقتصادية والبيئية.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @sector11.get_name_key, 'الحد من تأثير تغير المناخ والتكيف معه.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "Sector translations are created for EGSTEM"

  end

  ###################################################################################
  desc "create translations for dimension types"
  task dimension_translations: :environment do
    dim_translations_arr = [
      ['bigidea', 'Big Idea', 'فكرة هامة'],
      ['essq', 'Essential Question', 'السؤال الجوهري'],
      ['concept', 'Concept', 'مفهوم'],
      ['skill', 'Skill', 'مهارة'],
      ['miscon', 'Misconception', 'اعتقاد خاطئ'],
    ]
    @egstem.dim_codes.split(',').each do |dim|
      dim_name_key = Dimension.get_dim_type_key(
        dim[0],
        @egstem.code,
        @v01.code
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, dim_name_key, dim[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, dim_name_key, dim[2])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end
  ###################################################################################
  desc "Ensure default subject translations exist"
  task ensure_default_translations: :environment do
    default_subject_translations = [
      ['bio', 'Biology', 'مادة الاحياء'],
      ['cap', 'Capstones', 'كابستون'],
      ['che', 'Chemistry', 'كيمياء'],
      ['edu', 'Education', 'التعليم'],
      ['engl', 'English', 'الإنجليزية'],
      ['eng', 'Engineering', 'هندسة'],
      ['mat', 'Math', 'الرياضيات'],
      ['mec', 'Mechanics', 'علم الميكانيكا'],
      ['phy', 'Physics', 'الفيزياء'],
      ['sci', 'Science', 'علم'],
      ['ear', 'Earth Science', 'علوم الأرض'],
      ['geo', 'Geology', 'جيولوجيا'],
      ['tech', 'Tech Engineering', 'هندسة التكنولوجيا'],
    ]

    default_subject_translations.each do |s|
      name_key = Subject.get_default_name_key(s[0])
      abbr_key = Subject.get_default_abbr_key(s[0])
        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, name_key, s[1])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, abbr_key, s[0])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        puts "Saved Default English Translations for #{s[0]}"

        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, name_key, s[2])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, abbr_key, s[2])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        puts "Saved Default Arabic Translations for #{s[0]}"
    end

    rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'app.title', 'Curriculum')
    throw "ERROR updating default app title translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, 'app.title', 'منهاج دراسي')
    throw "ERROR updating default app title translation: #{message}" if status == BaseRec::REC_ERROR
    puts "Saved Default app title translations in English and Arabic"
  end #task
end
