# seed_eg_stessa_1rake
namespace :seed_eg_stem do

  task populate: [:setup, :create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors, :dimension_translations, :outcome_translations, :tree_resource_translations, :user_form_translations, :ensure_default_translations, :create_config]

  task setup: :environment do
    @versionNum = 'v01'
    @curriculumCode = 'egstem'
    @sectorCode = 'gr_chall'
  end

  ###################################################################################
  # set up Curriculum Tree Type and Version

  desc "create the tree type(s)"
  task create_tree_type: :environment do

    # reference version record from seeds.rb
    @v01 = Version.where(code: 'v01').first
    throw "Missing version record" if !@v01
    @ver = @v01

    # create Tree Type record for the Curriculum
    myTreeTypes = TreeType.where(code: 'egstemuniv')
    myTreeTypeValues = {
      code: 'egstemuniv',
      hierarchy_codes: 'grade,sem,unit,lo,indicator',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_AR_EG,
      sector_set_code: 'gr_chall,hide',
      sector_set_name_key: 'sector.set.gr_chall.name',
      curriculum_title_key: 'curriculum.egstemuniv.title', #'Egypt STEM Teacher Prep Curriculum'
      outcome_depth: 3,
      version_id: @v01.id,
      working_status: true,
      dim_codes: 'bigidea,miscon',
      tree_code_format: 'subject,grade,sem,unit,lo',
      # To Do: Write documentation on obtaining translation keys
      # - for dimension translation use dim.get_dim_resource_key
      # NOTE: Please avoid underscores (_) and commas (,)
      #       in item names.
      #
      # Detail headers notation key:
      #   item - HEADER
      #   [r#item] - TABLE item, outcome level connected dimension.
      #   {r#n} - TABLE item, outcome resource translation
      #   <item> - TABLE item, sectors
      #   +item+ - TABLE item, treetrees
      #   {depthCode#n#...} - TABLE item collection, multiple resource translations for tree at the given depth
      #                     - depthCode should be 'o' for outcome resources
      #                     - unit#n =lookup in Tree::RESOURCE_TYPES, else lookup in Outcome::RESOURCE_TYPES
      #   {resources#n#...} - TABLE item, full width of table,
      #                  with numeric codes identifying which
      #                  categories of this item to display.
      #                  e.g., may use indexes in the
      #                  Outcome::RESOURCE_TYPES array.
      #   tableItem_tableItem_... - up to 4 columns table items allowed in one row.
      #   To Do: standards header on top RIGHT of the show page.
      detail_headers: 'grade,sem,unit,lo,[o#bigidea],{o#6},[o#miscon],<sector>,+treetree+,{resources#0#1#2#3#4#5}',
      grid_headers: 'grade,unit,lo,[bigidea],[miscon]',
      #Display codes are zero-relative indexes in Dimension::RESOURCE_TYPES
      #Dimensions must appear in this string to have a show page
      #E.g., dim_display: 'miscon#0#1#2#3,bigidea#4#5#8,concept#1',
      dim_display: 'miscon#0#8#1#2#3#4#5#6#7',
      #user_form_config:
      #_form_other: list fields that should be included in the user form
        #dropdown selection fields should have the number of selection options
        #Dropdown categories in views/users/_form_other.html.erb such as institute_type
        #should be followed by a sharp (#) and the number of options for this field (not zero-relative).
        #Use @treeTypeRec.user_form_option_key(version_code, form_field_name, option_index) to set Translation
        #keys for the dropdown options.
      #_form_flag: role_rolename (e.g., role_admin,role_counselor,...)
      #ADD DROPDOWN TRANSLATIONS WITH TASK: user_form_translations
      user_form_config:'given_name,family_name,municipality,institute_type#7,institute_name_loc,position_type#6,subject1,subject2,gender,work_phone,role_admin,role_teacher,role_counselor,role_supervisor',
    }
    if myTreeTypes.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeTypes.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'egstemuniv').count != 1
    @tt = TreeType.where(code: 'egstemuniv').first

    puts "Create Default app title translations in English and Arabic"
    rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'app.title', 'Egyptian STEM Curriculum App')
    throw "ERROR updating default app title translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, 'app.title', 'منهج مصر للعلوم والتكنولوجيا والهندسة والرياضيات')
    throw "ERROR updating default app title translation: #{message}" if status == BaseRec::REC_ERROR

    # Create ENGLISH translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.hierarchy_name_key('grade'), 'Grade')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.hierarchy_name_key('sem'), 'Semester')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.hierarchy_name_key('unit'), 'Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.hierarchy_name_key('lo'), 'Learning Outcome')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
puts "SECTOR SET NAME KEY: #{@tt.sector_set_name_key}"
    # Enter ENGLISH translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.sector_set_name_key, 'Grand Challenges')
    throw "ERROR updating #{@tt.sector_set_name_key}: #{message}" if status == BaseRec::REC_ERROR

    # Enter ENGLISH translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.title_key, 'Egypt STEM Teacher Prep Curriculum')
    throw "ERROR updating curriculum.egstem.title translation: #{message}" if status == BaseRec::REC_ERROR

    # Create ARABIC translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.hierarchy_name_key('grade'), 'درجة')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.hierarchy_name_key('sem'), 'نصف السنة')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.hierarchy_name_key('unit'), 'وحدة')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.hierarchy_name_key('lo'), 'نتائج التعلم')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR


    # Enter ARABIC translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.sector_set_name_key, 'التحديات الكبرى')
    throw "ERROR updating #{@tt.sector_set_name_key}: #{message}" if status == BaseRec::REC_ERROR

    # Enter ARABIC translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.title_key, 'مصر STEM معلم إعداد المنهج')
    throw "ERROR updating curriculum.egstem.title translation: #{message}" if status == BaseRec::REC_ERROR


    puts "Curriculum (Tree Type) is created for egstemuniv "
    puts "  Created Curriculum: #{@tt.code} with Hierarchy: #{@tt.hierarchy_codes}"
  end #create_tree_type


  ###################################################################################
  desc "load up the locales (created in seeds.rb seed file)"
  task load_locales: :environment do
    @loc_en = Locale.where(code: 'en').first
    @loc_en = Locale.create(code: 'en', name: 'English') if !@loc_en
    @loc_ar_EG = Locale.where(code: 'ar_EG').first
    @loc_ar_EG = Locale.create(code: 'ar_EG', name: 'العربية (مصر)') if !@loc_ar_EG
    puts "Locales: #{@loc_en.code}: #{@loc_en.name}, #{@loc_ar_EG.code}: #{@loc_ar_EG.name}"
    @loc_other = @loc_ar_EG
  end #load_locales

  ###################################################################################
  desc "create the admin user(s)"
  task create_admin_user: :environment do
    # create an initial admin user to get things going.
    # Note: the Curriculum to display by default is EGSTEM tree type
    # to do - turn off admin flag for production.
    if User.where(email: 'admin@sample.com').count < 1
      User.create(
        email: 'admin@sample.com',
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
        last_tree_type_id: @tt
      )
    end
    @user = User.where(email: 'admin@sample.com').first
    puts "admin user is created for stessa 1 curriculum"
  end #create_admin_user


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    sort_counter = 0
    %w(fresh soph junior senior).each do |g|
      begin
        gf = (g == 'k') ? 0 : sort_counter
        if GradeBand.where(tree_type_id: @tt.id, code: g).count < 1
          GradeBand.create(
            tree_type_id: @tt.id,
            code: g,
            sort_order: gf
          )
        end
        sort_counter += 1
      rescue => ex
        puts("exception creating gradeband #{g}, error: #{ex}")
      end
    end

    @gb_fresh = GradeBand.where(tree_type_id: @tt.id, code: 'fresh').first
    @gb_soph = GradeBand.where(tree_type_id: @tt.id, code: 'soph').first
    @gb_junior = GradeBand.where(tree_type_id: @tt.id, code: 'junior').first
    @gb_senior = GradeBand.where(tree_type_id: @tt.id, code: 'senior').first
    @gb_univ = [@gb_fresh, @gb_soph, @gb_junior, @gb_senior]
    puts "grade bands are created for EGSTEM"

    # put in translations for Grade Names
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, GradeBand.build_name_key(@tt.code, 'fresh'), 'Freshman')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, GradeBand.build_name_key(@tt.code, 'soph'), 'Sophmore')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, GradeBand.build_name_key(@tt.code, 'junior'), 'Junior')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, GradeBand.build_name_key(@tt.code, 'senior'), 'Senior')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
     default_subject_translations = [
    ]
    @subjectsHash = {

      # note if a subject is in the Library, it must be in this hash
      bio: {abbr: 'bio', inCurric: true, engName: 'Biology', locAbbr: 'مادة الاحياء', locName: 'مادة الاحياء'},
      cap: {abbr: 'cap', inCurric: true, engName: 'Capstones', locAbbr: 'كابستون', locName: 'كابستون'},
      che: {abbr: 'chem', inCurric: true, engName: 'Chemistry', locAbbr: 'كيمياء', locName: 'كيمياء'},
      edu: {abbr: 'edu', inCurric: true, engName: 'Education', locAbbr: 'التعليم', locName: 'التعليم'},
      engl: {abbr: 'engl', inCurric: true, engName: 'English', locAbbr: 'الإنجليزية', locName: 'الإنجليزية'},
      eng: {abbr: 'eng', inCurric: false, engName: 'Engineering', locAbbr: 'هندسة', locName: 'هندسة'},
      mat: {abbr: 'math', inCurric: true, engName: 'Mathematics', locAbbr: 'الرياضيات', locName: 'الرياضيات'},
      mec: {abbr: 'mec', inCurric: true, engName: 'Mechanics', locAbbr: 'علم الميكانيكا', locName: 'علم الميكانيكا'},
      phy: {abbr: 'phy', inCurric: true, engName: 'Physics', locAbbr: 'الفيزياء', locName: 'الفيزياء'},
      sci: {abbr: 'sci', inCurric: false, engName: 'Science', locAbbr: 'علم', locName: 'علم'},
      ear: {abbr: 'ear', inCurric: false, engName: 'Earth Science', locAbbr: 'علوم الأرض', locName: 'علوم الأرض'},
      geo: {abbr: 'geo', inCurric: true, engName: 'Geology', locAbbr: 'جيولوجيا', locName: 'جيولوجيا'},
      tech: {abbr: 'tech', inCurric: false, engName: 'Tech Engineering', locAbbr: 'هندسة التكنولوجيا', locName: 'هندسة التكنولوجيا'}
    }

    @subjectsHash.each do |key, subjHash|

      # create the subject for this tree type
      # note: using default start and end grade
      # - need to be set: set_min_max_grades:run rake task after uploads are done
      puts "find subject tree_type_id: #{@tt.id}, code: #{subjHash[:abbr]}"
      subjs = Subject.where(tree_type_id: @tt.id, code: key)
      if subjs.count < 1
        puts "Creating Subject for #{key}"
        subj = Subject.create(
          tree_type_id: @tt.id,
          code: key,
          base_key: "subject.#{@tt.code}.#{@ver.code}.#{key}"
        )
      else
        subj = subjs.first
      end

      # create english translation for subject name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@tt.code}.#{@ver.code}.#{key}.name", subjHash[:engName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      # create english translation for subject abbreviation
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@tt.code}.#{@ver.code}.#{key}.abbr", subjHash[:abbr])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      if subjHash[:inCurric]

        if subjHash[:locName].present?
          # create locale's translation for subject name
          rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, "subject.#{@tt.code}.#{@ver.code}.#{key}.name", subjHash[:locName])
          throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
        end

        if subjHash[:locAbbr].present?
          # create locale's translation for subject abbreviation
          rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, "subject.#{@tt.code}.#{@ver.code}.#{key}.abbr", subjHash[:locAbbr])
          throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
        end

        puts "create upload for subject: #{subj.id} #{subj.code}"
        if Upload.where(tree_type_code: @curriculumCode,
          subject_id: subj.id,
          grade_band_id: nil,
          locale_id: @loc_en.id
        ).count < 1
          Upload.create!(
            tree_type_code: @curriculumCode,
            subject_id: subj.id,
            grade_band_id: nil,
            locale_id: @loc_en.id,
            status: 0,
            filename: "#{@tt.code}#{@ver.code}#{subj.code.capitalize}All#{@loc_en.code}.csv"
          )
        end

        if Upload.where(tree_type_code: @curriculumCode,
            subject_id: subj.id,
            grade_band_id: nil,
            locale_id: @loc_other.id
          ).count < 1
          Upload.create!(
            tree_type_code: @curriculumCode,
            subject_id: subj.id,
            grade_band_id: nil,
            locale_id: @loc_other.id,
            status: 0,
            filename: "#{@tt.code}#{@ver.code}#{subj.code.capitalize}All#{@loc_other.code}.csv"
          )
        end

      end

    end
  end
  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do

  end #create_uploads


  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
     @sectorsHash = {
      '1': {code: '1', engName: 'Deal with population growth and its consequences.',locName: 'التعامل مع النمو السكاني وعواقبه.'},
      '2': {code: '2', engName: 'Improve the use of alternative energies.', locName: 'تحسين استخدام الطاقات البديلة.'},
      '3': {code: '3', engName: 'Deal with urban congestion and its consequences.', locName: 'التعامل مع الازدحام الحضري وعواقبه.'},
      '4': {code: '4', engName: 'Improve the scientific and technological environment for all.', locName: 'تحسين البيئة العلمية والتكنولوجية للجميع.'},
      '5': {code: '5', engName: 'Work to eradicate public health issues/disease.', locName: 'العمل على القضاء على قضايا / أمراض الصحة العامة.'},
      '6': {code: '6', engName: 'Improve uses of arid areas.', locName: 'تحسين استخدامات المناطق الجافة.'},
      '7': {code: '7', engName: 'Manage and increase the sources of clean water.', locName: 'إدارة وزيادة مصادر المياه النظيفة.'},
      '8': {code: '8', engName: 'Increase the industrial and agricultural bases of Egypt.', locName: 'زيادة القواعد الصناعية والزراعية لمصر.'},
      '9': {code: '9', engName: 'Address and reduce pollution fouling our air, water and soil.', locName: 'معالجة وتقليل التلوث الناتج عن الهواء والماء والتربة.'},
      '10': {code: '10', engName: 'Recycle garbage and waste for economic and environmental purposes.', locName: 'إعادة تدوير القمامة والنفايات للأغراض الاقتصادية والبيئية.'},
      '11': {code: '11', engName: 'Reduce and adapt to the effect of climate change.', locName: 'الحد من تأثير تغير المناخ والتكيف معه.'}
    }
    @sectorsHash.each do |key, sectHash|

      # create the sector
      puts "create the sector: #{@sectorCode}, #{sectHash[:code]}"
      sectors = Sector.where(sector_set_code: @sectorCode, code: sectHash[:code])
      if sectors.count < 1
        sector = Sector.create(
          sector_set_code: @sectorCode,
          code: sectHash[:code],
          name_key: "sector.#{@sectorCode}.#{sectHash[:code]}.name",
          base_key: "sector.#{@sectorCode}.#{sectHash[:code]}"
        )
      else
        sector = sectors.first
      end

      # create the English translation for the Sector Name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "sector.#{@sectorCode}.#{sectHash[:code]}.name", sectHash[:engName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      # create the Locale's translation for the Sector Name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, "sector.#{@sectorCode}.#{sectHash[:code]}.name", sectHash[:locName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    end
    puts "Sector translations are created for sector set: #{@sectorCode}"

  end #create_sectors

   ###################################################################################
  desc "create translations for dimension types"
  task dimension_translations: :environment do
    dim_translations_arr = [
      ['bigidea', 'Big Idea', 'فكرة هامة'],
      ['miscon', 'Misconception', 'اعتقاد خاطئ'],
    ]

    dim_resource_types_arr = [
      ['Second Category', 'الفئة الثانية'],
      ['Correct Understanding', 'الفهم الصحيح'],
      ['Possible Source of Misconception', 'مصدر محتمل للفهم الخاطئ'],
      ['Compiler/Source'],
      ['Primary Research Citation', 'مترجم / المصدر'],
      ['Website Link References', 'مراجع رابط الموقع'],
      ['Test Distractor Percent', 'اختبار نسبة تشتيت الانتباه'],
      ['Link to Question Item Bank', 'رابط إلى بنك عناصر السؤال'],
      ['Third Category', 'الفئة الثالثة'],
    ]
    dim_translations_arr.each do |dim|
      dim_name_key = Dimension.get_dim_type_key(
        dim[0],
        @tt.code,
        @ver.code
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, dim_name_key, dim[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, dim_name_key, dim[2])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
    dim_resource_types_arr.each_with_index do |resource, i|
      resource_name_key = Resource.get_type_key(
        @tt.code,
        @ver.code,
        Dimension::RESOURCE_TYPES[i],
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, resource_name_key, resource[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end

  ###################################################################################
  desc "create translations for outcome resources"
  task outcome_translations: :environment do
    outc_resource_types_arr = [
      ["Multi, inter or trans disciplinary Grand Challenges based projects", "المشاريع القائمة على التحديات الكبرى المتعددة أو بين التخصصات"],
      ["Daily Lesson Plans", "خطط الدروس اليومية"],
      ["Textbook and Resource Materials to Use in Class", "الكتب والمواد الدراسية لاستخدامها في الفصل"],
      ["Suggested Assessment Resources and Activities", "موارد وأنشطة التقييم المقترحة"],
      ["Additional Background and Resource Materials for the Teacher", "معلومات أساسية وموارد إضافية للمعلم"],
      ["Goal behaviour (What students will do, Practical learning targets)", "سلوك الهدف (ما سيفعله الطلاب ، أهداف التعلم العملية)"],
      ["Reviewer Comments", "دعم المعلم"],
      ["Evidence of Learning", "دليل التعلم"],
      ["Capstone Connection", "روابط"],
      ["SEC Topic", "موضوع SEC"],
      ["SEC Code", "كود SEC"],
      ["SEC Cognitive Demand", "الطلب المعرفي SEC"],
      ["Daily Lesson Plans", "خطط الدروس اليومية"], #LP as a spreadsheet ID, processed differently than the LP at index 1.
      ["WL Review Comments", "تعليقات مراجعة WL"]
    ]

    outc_resource_types_arr.each_with_index do |resource, i|
      resource_name_key = Resource.get_type_key(
        @tt.code,
        @ver.code,
        Outcome::RESOURCE_TYPES[i],
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, resource_name_key, resource[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end

  ###################################################################################
  desc "create translations for outcome resources"
  task tree_resource_translations: :environment do
    tree_resource_types_arr = [
      # ["Course Materials", "مواد الدورة"],
      # ["Semester Materials", "مواد الفصل"],
      # ["Unit Materials", "مواد الوحدة"],
      # ["Semester Lesson Plans Folder", "مجلد خطط الدرس للفصل الدراسي"],
      # ["Semester Theme", "موضوع الفصل"]
    ]

    tree_resource_types_arr.each_with_index do |resource, i|
      # resource_name_key = Tree.get_resource_type_key(
      #   Tree::RESOURCE_TYPES[i],
      #   @tt.code,
      #   @ver.code
      # )
      # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
      # throw "ERROR updating tree resource translation: #{message}" if status == BaseRec::REC_ERROR
      # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, resource_name_key, resource[1])
      # throw "ERROR updating tree resource translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end

  ####################################################################################
  desc "Translation for user form dropdown options"
  task user_form_translations: :environment do
  #  position_type#6
  #  @tt.user_form_option_key(version_code, form_field_name, option_num)
    dropdown_opts = [
      {ix: 1, field: 'institute_type', en: 'MOE Counselors', ar_EG: 'مستشارو وزارة التربية'},
      {ix: 2, field: 'institute_type', en: 'STEM Unit', ar_EG: 'وحدة العلوم والتكنولوجيا والهندسة والرياضيات'},
      {ix: 3, field: 'institute_type', en: 'PAT', ar_EG: 'PAT'},
      {ix: 4, field: 'institute_type', en: 'Governorate Level Supervisors', ar_EG: 'المشرفون على مستوى المحافظة'},
      {ix: 5, field: 'institute_type', en: 'STEM School', ar_EG: 'مدرسة STEM'},
      {ix: 6, field: 'institute_type', en: 'University', ar_EG: 'جامعة'},
      {ix: 7, field: 'institute_type', en: 'STESSA Project', ar_EG: 'مشروع STESSA'},
      {ix: 1, field: 'position_type', en: 'School Leader', ar_EG: 'قائد المدرسة'},
      {ix: 2, field: 'position_type', en: 'Teacher', ar_EG: 'مدرس'},
      {ix: 3, field: 'position_type', en: 'MOE Counselor', ar_EG: ''},
      {ix: 4, field: 'position_type', en: 'STEM Unit Member', ar_EG: 'مستشار وزارة التربية'},
      {ix: 5, field: 'position_type', en: 'Governorate Supervisor', ar_EG: 'مشرف محافظة'},
      {ix: 6, field: 'position_type', en: 'STESSA Project Staff', ar_EG: 'طاقم مشروع STESSA'},
    ]
    dropdown_opts.each do |opt|
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.user_form_option_key(@ver.code, opt[:field], opt[:ix]), opt[:en])
      throw "ERROR updating user dropdown option translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.user_form_option_key(@ver.code, opt[:field], opt[:ix]), opt[:ar_EG])
      throw "ERROR updating user dropdown option translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end

  ##################################################################################
  desc "create tree type config"
  task create_config: :environment do
    tree_type_config = [
      ########################
      #TREE DETAIL PAGE CONFIG
      #######################
      #Subject
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 0,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "Subject",
        resource_code: nil,
        table_partial_name: "simple_header"
      },
      #grade header
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 1,
        col_sequence: 0,
        tree_depth: 0, #hierarchy depth 0 == grade
        item_lookup: nil,
        resource_code: nil,
        table_partial_name: "simple_header"
      },
      #semester header
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 3,
        col_sequence: 0,
        tree_depth: 1,
        item_lookup: nil,
        resource_code: nil,
        table_partial_name: "simple_header"
      },
      #unit header
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 7,
        col_sequence: 0,
        tree_depth: 2,
        item_lookup: nil,
        resource_code: nil,
        table_partial_name: "simple_header"
      },
      #Learning Outcome header
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 9,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: nil,
        resource_code: nil,
        table_partial_name: "simple_header"
      },
      # Big Ideas Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 10,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "bigidea",
        table_partial_name: "generic_table"
      },
      #Reviewer Comments Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 12,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "Outcome",
        resource_code: "explain", #teacher support/explanatory comments
        table_partial_name: "generic_table"
      },
      #Misconceptions Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 13,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "miscon&href",
        resource_code: nil,
        table_partial_name: "generic_table"
      },
      #Misconceptions Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 13,
        col_sequence: 1,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "miscon",
        resource_code: "poss_source_miscon",
        table_partial_name: "generic_table"
      },
      #Misconceptions Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 13,
        col_sequence: 2,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "miscon",
        resource_code: "correct_understanding",
        table_partial_name: "generic_table"
      },
      #Grand Challenges Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 14,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "Sector",
        table_partial_name: "generic_table"
      },
      #Connected Learning Outcomes Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 19,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: "TreeTree",
        table_partial_name: "treetree"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 20,
        col_sequence: 0,
        tree_depth: @tt[:outcome_depth],
        item_lookup: 'Outcome',
        resource_code: Outcome::RESOURCE_TYPES[0],
        table_partial_name: "resources"
      },
      #Resources Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 20,
        col_sequence: 1,
        tree_depth: @tt[:outcome_depth],
        item_lookup: 'Outcome',
        resource_code: Outcome::RESOURCE_TYPES[1],
        table_partial_name: "resources"
      },
      #Resources Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 20,
        col_sequence: 2,
        tree_depth: @tt[:outcome_depth],
        item_lookup: 'Outcome',
        resource_code: Outcome::RESOURCE_TYPES[2],
        table_partial_name: "resources"
      },
      #Resources Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 20,
        col_sequence: 3,
        tree_depth: @tt[:outcome_depth],
        item_lookup: 'Outcome',
        resource_code: Outcome::RESOURCE_TYPES[3],
        table_partial_name: "resources"
      },
      #Resources Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 20,
        col_sequence: 4,
        tree_depth: @tt[:outcome_depth],
        item_lookup: 'Outcome',
        resource_code: Outcome::RESOURCE_TYPES[4],
        table_partial_name: "resources"
      },
      #Resources Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig::TREE_DETAIL_NAME,
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 20,
        col_sequence: 5,
        tree_depth: @tt[:outcome_depth],
        item_lookup: 'Outcome',
        resource_code: Outcome::RESOURCE_TYPES[5],
        table_partial_name: "resources"
      },
      #################################
      # Misconceptions Detail page config
      # ##############################
      # Misconception Name Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 0,
        col_sequence: 0,
        table_partial_name: "simple_header"
      },
      # Subject Name Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 1,
        col_sequence: 0,
        item_lookup: "Subject",
        table_partial_name: "simple_header"
      },
      # Grades Name Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::HEADERS,
        table_sequence: 2,
        col_sequence: 0,
        item_lookup: "min_max_grade",
        table_partial_name: "simple_header"
      },
      # Second Category Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 3,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "second_subj",
        table_partial_name: "generic_table"
      },
      # Third Category Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "third_subj",
        table_partial_name: "generic_table"
      },
      # Correct Understanding Table
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "correct_understanding",
        table_partial_name: "generic_table"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "poss_source_miscon",
        table_partial_name: "generic_table"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "compiler",
        table_partial_name: "generic_table"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "citation",
        table_partial_name: "generic_table"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "link",
        table_partial_name: "generic_table"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "distractor",
        table_partial_name: "generic_table"
      },
      { tree_type_id: @tt.id,
        version_id: @ver.id,
        page_name: TreeTypeConfig.dim_page_name('miscon'),
        config_div_name: TreeTypeConfig::TABLES,
        table_sequence: 4,
        col_sequence: 0,
        item_lookup: "ResourceJoin",
        resource_code: "question_bank",
        table_partial_name: "generic_table"
      },
    ]
    TreeTypeConfig.where(
        tree_type_id: @tt.id,
        version_id: @ver.id,
      ).delete_all
    tree_type_config.each do |config|
      myConfig = TreeTypeConfig.create(config)
      puts "Created config for page: #{myConfig.page_name}, section: #{myConfig.config_div_name}, table_num: #{myConfig.table_sequence}"
    end # create or update config records
  end

  ###################################################################################
  desc "Ensure default subject translations exist"
  task ensure_default_translations: :environment do

  end #task

  #############
end
