# seed_stessa_2.rake
namespace :seed_stessa_2 do


  task populate: [:setup, :create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors, :dimension_translations, :ensure_default_translations]

  task setup: :environment do
    @versionNum = 'v01'
    @curriculumCode = 'egstem'
    @sectorCode = 'gr_chall'
  end

  ###################################################################################
  desc "create the Curriculum Tree Type and Version for STEM Egypt High School Curriculum - Is Rerunnable!"
  task create_tree_type: :environment do

    # reference version record from seeds.rb
    myVersion = Version.where(:code => @versionNum)
    if myVersion.count > 0
      @ver = myVersion.first
    else
      @ver = Version.new
      @ver.code = @versionNum
      @ver.save
      @ver.reload
    end

    # create Tree Type record for the Curriculum
    myTreeType = TreeType.where(code: @curriculumCode, version_id: @ver.id)
    myTreeTypeValues = {
      code: @curriculumCode,
      hierarchy_codes: 'grade,sem,unit,lo',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_AR_EG,
      sector_set_code: 'gr_chall',
      sector_set_name_key: 'sector.set.gr_chal.name',
      curriculum_title_key: 'curriculum.egstem.title', # 'Egypt STEM Curriculum - deprecated - see treeType.title_key'
      outcome_depth: 3,
      version_id: @ver.id,
      working_status: true,
      dim_codes: 'bigidea,essq,concept,skill,miscon',
      tree_code_format: 'subject,grade,lo',
      # To Do: Write documentation on obtaining translation keys
      # - for dimension translation use dim.get_dim_ref_key
      #
      # Detail headers notation key:
      #   item - HEADER
      #   (item) - optional HEADER item
      #   [item] - TABLE item, full width of table,
      #            may be multiple connected items of this type.
      #   {item} - TABLE item, full width of table
      #   <item< - TABLE item, left side column (of two),
      #            must be followed by >item>
      #   >item> - TABLE item, right side column (of two),
      #            must follow <item<
      #   <item> - TABLE item, full width of table with two cols:
      #          item | item resources
      #   [item#n#...] - TABLE item, full width of table,
      #                  with numeric codes identifying which
      #                  categories of this item to display.
      #                  e.g., may use indexes in the
      #                  Outcome::RESOURCE_TYPES array.
      detail_headers: 'grade,unit,lo,weeks,hours,<bigidea<,>essq>,<concept<,>skill>,[miscon],[sector],[connect],[resource#1#3#2]',
      grid_headers: 'grade,unit,lo,[bigidea],[essq],[concept],[skill],[miscon]',
      #Display codes are zero-relative indexes in Dimension::RESOURCE_TYPES
      #Dimensions must appear in this string to have a show page
      #E.g., dim_display: 'miscon#0#1#2#3,bigidea#4#5#8,concept#1',
      dim_display: 'miscon#0#1#2#3#4#5#6#7',
    }
    if myTreeType.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    treeTypes = TreeType.where(code: @curriculumCode, version_id: @ver.id)
    throw "ERROR: Missing tfv tree type" if treeTypes.count < 1
    @tt = treeTypes.first

    puts "Create Default app title translations in English and Arabic"
    rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'app.title', 'Curriculum')
    throw "ERROR updating default app title translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, 'app.title', 'منهاج دراسي')
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


    # Enter ENGLISH translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.sector_set_name_key, 'Grand Challenges')
    throw "ERROR updating #{@tt.sector_set_name_key}: #{message}" if status == BaseRec::REC_ERROR

    # Enter ENGLISH translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, @tt.title_key, 'Egypt STEM Curriculum')
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
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, @tt.title_key, 'منهاج مصر للعلوم والتكنولوجيا والهندسة والرياضيات')
    throw "ERROR updating curriculum.egstem.title translation: #{message}" if status == BaseRec::REC_ERROR


    puts "Curriculum (Tree Type) is created for #{@curriculumCode}"
    puts "  Created Curriculum: #{@tt.code} with Hierarchy: #{@tt.hierarchy_codes}"
  end #create_tree_type


  ###################################################################################
  desc "load up the locales (created in seeds.rb seed file)"
  task load_locales: :environment do
    @loc_en = Locale.where(code: 'en').first
    @loc_ar_EG = Locale.where(code: 'ar_EG').first
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
        family_name: 'Curriculum',
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
    puts "admin user is created for  #{@curriculumCode}  curriculum"
  end #create_admin_user


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    sort_counter = 0
    %w(1 2 3).each do |g|
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
    puts "grade bands are created for egstem"
    # put in translations for Grade Names
    (1..3).each do |g|
      puts "Create Grade Band translation #{GradeBand.build_name_key(@tt.code, g.to_s)} for Grade #{g}"
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, GradeBand.build_name_key(@tt.code, "#{g}"), "Grade #{g}")
      throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, GradeBand.build_name_key(@tt.code, "#{g}"), "#{g} الصف")
      throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    default_subject_translations = [
    ]
    @subjectsHash = {

      # note if a subject is in the Library, it must be in this hash
      bio: {abbr: 'bio', inCurric: true, engName: 'Biology', locAbbr: 'مادة الاحياء', locName: 'مادة الاحياء'},
      cap: {abbr: 'cap', inCurric: false, engName: 'Capstones', locAbbr: 'كابستون', locName: 'كابستون'},
      che: {abbr: 'Chem', inCurric: true, engName: 'Chemistry', locAbbr: 'كيمياء', locName: 'كيمياء'},
      edu: {abbr: 'edu', inCurric: false, engName: 'Education', locAbbr: 'التعليم', locName: 'التعليم'},
      engl: {abbr: 'engl', inCurric: false, engName: 'English', locAbbr: 'الإنجليزية', locName: 'الإنجليزية'},
      eng: {abbr: 'eng', inCurric: false, engName: 'Engineering', locAbbr: 'هندسة', locName: 'هندسة'},
      mat: {abbr: 'Math', inCurric: true, engName: 'Mathematics', locAbbr: 'الرياضيات', locName: 'الرياضيات'},
      mec: {abbr: 'mec', inCurric: false, engName: 'Mechanics', locAbbr: 'علم الميكانيكا', locName: 'علم الميكانيكا'},
      phy: {abbr: 'phy', inCurric: false, engName: 'Physics', locAbbr: 'الفيزياء', locName: 'الفيزياء'},
      sci: {abbr: 'sci', inCurric: false, engName: 'Science', locAbbr: 'علم', locName: 'علم'},
      ear: {abbr: 'Ear', inCurric: false, engName: 'Earth Science', locAbbr: 'علوم الأرض', locName: 'علوم الأرض'},
      geo: {abbr: 'geo', inCurric: false, engName: 'Geology', locAbbr: 'جيولوجيا', locName: 'جيولوجيا'},
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
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.name", subjHash[:engName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      # create english translation for subject abbreviation
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.abbr", subjHash[:abbr])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      if subjHash[:inCurric]

        if subjHash[:locName].present?
          # create locale's translation for subject name
          rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.name", subjHash[:locName])
          throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
        end

        if subjHash[:locAbbr].present?
          # create locale's translation for subject abbreviation
          rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, "subject.#{@tt.code}.#{@ver.code}.#{subjHash[:abbr]}.abbr", subjHash[:locAbbr])
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

    ##################################################################
    BaseRec::BASE_SUBJECTS.each do |subjCode|
      puts "set up library subject for #{subjCode}"
      # Create the English name and abbreviation for the Subjects in the Library.
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_abbr_key(subjCode), @subjectsHash[subjCode.to_sym][:abbr])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_name_key(subjCode), @subjectsHash[subjCode.to_sym][:engName])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR

      # Create the Locale's name and abbreviation for the Subjects in the Library.
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, Subject.get_default_abbr_key(subjCode), @subjectsHash[subjCode.to_sym][:locAbbr])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, Subject.get_default_name_key(subjCode), @subjectsHash[subjCode.to_sym][:locName])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
    end

  end #create_subjects


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

    dim_resource_types_arr = [
      ['Second Subject', 'الموضوع الثاني'],
      ['Correct Understanding', 'الفهم الصحيح'],
      ['Possible Source of Misconception', 'مصدر محتمل للفهم الخاطئ'],
      ['Compiler/Source'],
      ['Primary Research Citation', 'مترجم / المصدر'],
      ['Website Link References', 'مراجع رابط الموقع'],
      ['Test Distractor Percent', 'اختبار نسبة تشتيت الانتباه'],
      ['Link to Question Item Bank', 'رابط إلى بنك عناصر السؤال'],
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
      resource_name_key = Dimension.get_resource_key(
        Dimension::RESOURCE_TYPES[i],
        @tt.code,
        @ver.code
      )
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_AR_EG, resource_name_key, resource[1])
      throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end
  ###################################################################################
  desc "Ensure default subject translations exist"
  task ensure_default_translations: :environment do

  end #task
end
