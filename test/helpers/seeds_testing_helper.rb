module SeedsTestingHelper

  # deprecated - old seed method
  def testing_db_seeds

    #######################################
    # test version of db/seeds.rb
    # code below is copied from db/seeds.rb


    if Version.count < 1
      Version.create(
        code: 'v01'
      )
    end
    throw "Invalid Version Count" if Version.count > 1
    @v01 = Version.last

    if TreeType.count < 1
      TreeType.create(
        code: 'OTC'
      )
    end
    throw "Invalid TreeType Count" if TreeType.count > 1
    @otc = TreeType.last

    if Locale.count < 1
      Locale.create(
        code: 'bs',
        name: 'bosanski'
      )
      Locale.create(
        code: 'hr',
        name: 'hrvatski'
      )
      Locale.create(
        code: 'sr',
        name: 'српски'
      )
      loc_en = Locale.create(
        code: 'en',
        name: 'English'
      )
    end
    throw "Invalid Locale Count" if Locale.count != 4
    @loc_bs = Locale.first
    @loc_hr = Locale.second
    @loc_sr = Locale.third
    @loc_en = Locale.fourth

    if GradeBand.count < 4
      GradeBand.create(
        tree_type_id: @otc.id,
        code: '3'
      )
      GradeBand.create(
        tree_type_id: @otc.id,
        code: '6'
      )
      GradeBand.create(
        tree_type_id: @otc.id,
        code: '9'
      )
      GradeBand.create(
        tree_type_id: @otc.id,
        code: '13'
      )
    end

    throw "Invalid GradeBand Count" if GradeBand.count != 4
    @gb_03 = GradeBand.first
    @gb_06 = GradeBand.second
    @gb_09 = GradeBand.third
    @gb_13 = GradeBand.fourth
    @grade_bands = GradeBand.all

    if Subject.count != 6
      Subject.create(
        tree_type_id: @otc.id,
        code: 'Bio'
      )
      Subject.create(
        tree_type_id: @otc.id,
        code: 'Fiz'
      )
      Subject.create(
        tree_type_id: @otc.id,
        code: 'Geo'
      )
      Subject.create(
        tree_type_id: @otc.id,
        code: 'Hem'
      )
      Subject.create(
        tree_type_id: @otc.id,
        code: 'IT'
      )
      Subject.create(
        tree_type_id: @otc.id,
        code: 'Mat'
      )
    end
    throw "Invalid Subject Count" if Subject.count != 6
    @bio = Subject.first
    @fiz = Subject.second
    @geo = Subject.third
    @hem = Subject.fourth
    @it = Subject.fifth
    @mat = Subject.last
    @subjects = Subject.all


    if Upload.count != 62
      @subjects.each do |s|
        @grade_bands.each do |gb|
          # don't create grades 3 and 6 for Hem (Chemistry) and Fiz (Physics)
          if (
              !['Hem', 'Fiz'].include?(s.code) ||
              !['3', '6'].include?(gb.code)
            )
            Upload.create(
              subject_id: s.id,
              grade_band_id: gb.id,
              locale_id: @loc_bs.id,
              status: 0,
              filename: "#{s.code}_#{gb.code}_bs.csv"
            )
            Upload.create(
              subject_id: s.id,
              grade_band_id: gb.id,
              locale_id: @loc_hr.id,
              status: 0,
              filename: "#{s.code}_#{gb.code}_hr.csv"
            )
            Upload.create(
              subject_id: s.id,
              grade_band_id: gb.id,
              locale_id: @loc_sr.id,
              status: 0,
              filename: "#{s.code}_#{gb.code}_sr.csv"
            )
          end
        end
      end
      Upload.create(
        subject_id: @hem.id,
        grade_band_id: @gb_09.id,
        locale_id: @loc_en.id,
        status: 0,
        filename: 'Hem_9_en.csv'
      )
      Upload.create(
        subject_id: @hem.id,
        grade_band_id: @gb_13.id,
        locale_id: @loc_en.id,
        status: 0,
        filename: 'Hem_13_en.csv'
      )
    end
    # valid count:
    #   2 english
    #   + 72 (4 grade bands * 6 subjects * 3 languages)
    #   - 12 physics and chemistry for grades 3 and 6 for 3 languages
    #   = 62 valid uploads
    throw "Invalid Upload Count" if Upload.count != 62
    @hem_09 = Upload.where(filename: 'Hem_9_en.csv').first
    @hem_13 = Upload.where(filename: 'Hem_13_en.csv').first
    @bio_03 = Upload.where(filename: 'Bio_3_bs.csv').first



    ################################
    # Populate the Sector table and its translations for all four languages
    if Sector.count > 0 && Sector.count != 10
      throw "Invalid KBE Sector count #{Sector.count}"
    elsif Sector.count == 10
      # puts "Sectors entered already!"
      # entered already
    else
      Sector.create(code: '1', name_key: 'sector.1.name', base_key: 'sector.1')
      Sector.create(code: '2', name_key: 'sector.2.name', base_key: 'sector.2')
      Sector.create(code: '3', name_key: 'sector.3.name', base_key: 'sector.3')
      Sector.create(code: '4', name_key: 'sector.4.name', base_key: 'sector.4')
      Sector.create(code: '5', name_key: 'sector.5.name', base_key: 'sector.5')
      Sector.create(code: '6', name_key: 'sector.6.name', base_key: 'sector.6')
      Sector.create(code: '7', name_key: 'sector.7.name', base_key: 'sector.7')
      Sector.create(code: '8', name_key: 'sector.8.name', base_key: 'sector.8')
      Sector.create(code: '9', name_key: 'sector.9.name', base_key: 'sector.9')
      Sector.create(code: '10', name_key: 'sector.10.name', base_key: 'sector.10')
    end
    throw "Invalid Sector Count" if Sector.count != 10
    @sector1 = Sector.where(name_key: 'sector.1.name').first
    @sector2 = Sector.where(name_key: 'sector.2.name').first
    @sector3 = Sector.where(name_key: 'sector.3.name').first
    @sector4 = Sector.where(name_key: 'sector.4.name').first
    @sector5 = Sector.where(name_key: 'sector.5.name').first
    @sector6 = Sector.where(name_key: 'sector.6.name').first
    @sector7 = Sector.where(name_key: 'sector.7.name').first
    @sector8 = Sector.where(name_key: 'sector.8.name').first
    @sector9 = Sector.where(name_key: 'sector.9.name').first
    @sector10 = Sector.where(name_key: 'sector.10.name').first

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.1.name', 'Informaciono-komunikacijske tehnologije (IKT)')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.2.name', 'Zdravstvo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.4.name', 'Proizvodnja energije, prenos, efikasnost ')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.5.name', 'Finansije i biznis')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.6.name', 'Umjetnost, zabava i mediji')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.7.name', 'Sport')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.8.name', 'Turizam')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.9.name', 'Poduzetništvo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.10.name', 'Savremena poljoprivredna proizvodnja')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.1.name', 'Informacijske i komunikacijske tehnologije (IKT)')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.2.name', 'Zdravstvo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.4.name', 'Proizvodnja energije, prijenos, učinkovitost')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.5.name', 'Financije i poslovanje')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.6.name', 'Umjetnost, zabava i mediji')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.7.name', 'Sport')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.8.name', 'Turizam')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.9.name', 'Poduzetništvo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.10.name', 'Suvremena poljoprivredna proizvodnja')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.1.name', 'Инфoрмaтичко-кoмуникaциoнe тeхнoлoгиje (ИКТ)')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.2.name', 'Здрaвствo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.3.name', 'Teхнoлoгиja мaтeриjaлa и висoкoтeхнoлoшкa прoизвoдњa')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.4.name', 'Прoизвoдњa eнeргиje, прeнoс, eфикaснoст')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.5.name', 'Финaнсиje и бизнис')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.6.name', 'Умjeтнoст, зaбaвa и мeдиjи')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.7.name', 'Спoрт')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.8.name', 'Tуризaм')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.9.name', 'Предузетништво')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.10.name', 'Сaврeмeнa пoљoприврeднa прoизвoдњa')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.1.name', 'IT')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.2.name', 'Medicine and related sectors')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.3.name', 'Technology of materials')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.4.name', 'Energy generation, transmission and efficiency')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.5.name', 'Finance and business')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.6.name', 'Fine arts')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.7.name', 'Sport')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.8.name', 'Tourism')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.9.name', 'Entrepreneurship')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.10.name', 'Agricultural production')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

        #######################################
        # code above is copied from db/seeds.rb

  end # self.seed

  def testing_db_tfv_seed
    @versionNumTFV = 'v02'
    @curriculumCodeTFV = 'tfv'
    @sectorCodeTFV = 'future'

    @loc_en = Locale.where(code: 'en').first
    @loc_tr = Locale.where(code: 'tr').first
    @loc_en = Locale.create(code: 'en', name: 'English') if !@loc_en
    @loc_tr = Locale.create(code: 'tr', name: 'Türkçe') if !@loc_tr

    # reference version record from seeds.rb
    myVersion = Version.where(:code => @versionNumTFV)
    if myVersion.count > 0
      @verTFV = myVersion.first
    else
      @verTFV = Version.new
      @verTFV.code = @versionNumTFV
      @verTFV.save
      @verTFV.reload
    end

    # create Tree Type record for the Curriculum
    myTreeTypes = TreeType.where(code: @curriculumCodeTFV, version_id: @verTFV.id)
    myTreeTypeValues = {
      code: @curriculumCodeTFV,
      hierarchy_codes: 'grade,unit,subunit,comp',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_TR,
      sector_set_code: 'future,hide',
      sector_set_name_key: 'sector.set.future.name',
      curriculum_title_key: 'curriculum.tfv.title', # 'Mektebim STEM Curriculum'
      outcome_depth: 3,
      version_id: @verTFV.id,
      working_status: true,
      dim_codes: 'essq,bigidea,pract,miscon',
      tree_code_format: 'subject,grade,unit,subunit,comp',
      detail_headers: 'grade,unit,subunit,comp,[o#bigidea]_[o#essq],[o#pract],{o#6},[o#miscon#2#1],<sector>,+treetree+,{resources#0#1#2#3#4#5}',
      grid_headers: 'grade,unit,subunit,comp,[essq],[bigidea],[pract],{explain},[miscon]',
      dim_display: 'miscon#0#8#1#2#3#4#5#6#7', #To Do: update on server
    }
    if myTreeTypes.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeTypes.first.id, myTreeTypeValues)
    end
    treeTypes = TreeType.where(code: @curriculumCodeTFV, version_id: @verTFV.id)
    throw "ERROR: Missing tfv tree type" if treeTypes.count < 1
    @ttTFV = treeTypes.first

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'app.title', 'Mektebim STEM Curriculum App')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'app.title', 'Mektebim STEM Müfredat Uygulaması')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.grade', 'Grade')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.unit', 'Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    #STDOUT.puts 'Create translation record for essential questions as K-12 Big Ideas.'
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.subunit', 'Sub-Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    #STDOUT.puts 'Create translation record for Sub-Unit.'
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.comp', 'Competence')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for sector_set_name_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.set.future.name', 'Future Sectors')
    throw "ERROR updating sector.set.fut.sect.name: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for curriculum_title_key
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.title', 'Mektebim STEM Curriculum')
    throw "ERROR updating curriculum.tfv.title translation: #{message}" if status == BaseRec::REC_ERROR

    # # Titles of Turkish Dimension Pages (see seeds.rb for default english)
    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'trees.bigidea.title', "Büyük Fikirler")
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'trees.miscon.title', "Yanlış")
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #puts "Curriculum (Tree Type) is created for tfv "
    #puts "  Created Curriculum: #{@ttTFV.code} with Hierarchy: #{@ttTFV.hierarchy_codes}"


  ###################################################################################
  sort_counter = 0
  %w(k 1 2 3 4 5 6 7 8 9 10 11 12).each do |g|
    begin
      gf = (g == 'k') ? 0 : sort_counter
      if GradeBand.where(tree_type_id: @ttTFV.id, code: g).count < 1
        GradeBand.create(
          tree_type_id: @ttTFV.id,
          code: g,
          sort_order: gf,
          min_grade: gf,
          max_grade: gf
        )
      end
      sort_counter += 1
    rescue => ex
      #puts("exception creating gradeband #{g}, error: #{ex}")
    end
  end

  rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'grades.tfv.k.name', 'Kindergarten')
  throw "ERROR creating kindergarten translation: #{message}" if status == BaseRec::REC_ERROR
  [1..12].each do |g|
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "grades.tfv.#{g}.name", "Grade #{g}")
    throw "ERROR creating grade #{g} translation: #{message}" if status == BaseRec::REC_ERROR
  end

  @gb_09 = GradeBand.where(tree_type_id: @ttTFV.id, code: '9').first
  @gb_12 = GradeBand.where(tree_type_id: @ttTFV.id, code: '12').first

  ###################################################################################
  #create_subjects
  # Set Subject Abbreviations:
  @subjectsHashTFV = {
    bio: {abbr: 'bio', inCurric: true, engName: 'Biology', locAbbr: 'Biy', locName: 'Biyoloji'},
    cap: {abbr: 'cap', inCurric: false, engName: 'Capstones', locAbbr: '', locName: ''},
    che: {abbr: 'Chem', inCurric: true, engName: 'Chemistry', locAbbr: 'Kim', locName: 'Kimya'},
    edu: {abbr: 'edu', inCurric: false, engName: 'Education', locAbbr: '', locName: ''},
    engl: {abbr: 'engl', inCurric: false, engName: 'English', locAbbr: '', locName: ''},
    eng: {abbr: 'eng', inCurric: false, engName: 'Engineering', locAbbr: '', locName: ''},
    mat: {abbr: 'Math', inCurric: true, engName: 'Mathematics', locAbbr: 'Mat', locName: 'Matematik'},
    mec: {abbr: 'mec', inCurric: false, engName: 'Mechanics', locAbbr: '', locName: ''},
    phy: {abbr: 'phy', inCurric: true, engName: 'Physics', locAbbr: 'Fiz', locName: 'Fizik'},
    sci: {abbr: 'sci', inCurric: true, engName: 'Science', locAbbr: 'Bil', locName: 'Bilim'},
    ear: {abbr: 'Ear', inCurric: true, engName: 'Earth, Space, & Environmental Science', locAbbr: 'Dün', locName: 'Dünya, Uzay ve Çevre Bilimi'},
    geo: {abbr: 'geo', inCurric: false, engName: 'Geology', locAbbr: '', locName: ''},
    tech: {abbr: 'tech', inCurric: true, engName: 'Tech Engineering', locAbbr: '', locName: ''}
  }
  # @subjects = []

  @subjectsHashTFV.each do |key, subjHash|

    # create the subject for this tree type
    # note: using default start and end grade
    # - need to be set: set_min_max_grades:run rake task after uploads are done
    #puts "find subject tree_type_id: #{@ttTFV.id}, code: #{key}"
    subjs = Subject.where(tree_type_id: @ttTFV.id, code: key)
    if subjs.count < 1
      #puts "Creating Subject for #{key}"
      subj = Subject.create(
        tree_type_id: @ttTFV.id,
        code: key,
        base_key: "subject.#{@ttTFV.code}.#{@verTFV.code}.#{subjHash[:abbr]}"
      )
    else
      subj = subjs.first
    end

    # create english translation for subject name
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@ttTFV.code}.#{@verTFV.code}.#{subjHash[:abbr]}.name", subjHash[:engName])
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    # create english translation for subject abbreviation
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "subject.#{@ttTFV.code}.#{@verTFV.code}.#{subjHash[:abbr]}.abbr", subjHash[:abbr])
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    if subjHash[:inCurric]

      if subjHash[:locName].present?
        # create locale's translation for subject name
        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, "subject.#{@ttTFV.code}.#{@verTFV.code}.#{subjHash[:abbr]}.name", subjHash[:locName])
        throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      end

      if subjHash[:locAbbr].present?
        # create locale's translation for subject abbreviation
        rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, "subject.#{@ttTFV.code}.#{@verTFV.code}.#{subjHash[:abbr]}.abbr", subjHash[:locAbbr])
        throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      end

      if Upload.where(tree_type_code: @curriculumCodeTFV,
        subject_id: subj.id,
        grade_band_id: nil,
        locale_id: @loc_en.id
      ).count < 1
      #puts "create Eng upload for subject: #{subj.id} #{subj.code}"
        Upload.create!(
          tree_type_code: @curriculumCodeTFV,
          subject_id: subj.id,
          grade_band_id: nil,
          locale_id: @loc_en.id,
          status: 0,
          filename: "#{@ttTFV.code}#{@verTFV.code}#{subj.code.capitalize}AllEng.csv"
        )
      end
      if Upload.where(tree_type_code: @curriculumCodeTFV,
        subject_id: subj.id,
        grade_band_id: nil,
        locale_id: @loc_tr.id
      ).count < 1
        #puts "create Tur upload for subject: #{subj.id} #{subj.code}"
        Upload.create!(
          tree_type_code: @curriculumCodeTFV,
          subject_id: subj.id,
          grade_band_id: nil,
          locale_id: @loc_tr.id,
          status: 0,
          filename: "#{@ttTFV.code}#{@verTFV.code}#{subj.code.capitalize}AllTur.csv"
        )
      end

      if subj.code == 'bio' && Upload.where(tree_type_code: @curriculumCodeTFV,
        subject_id: subj.id,
        grade_band_id: nil,
        locale_id: @loc_en.id
      ).count < 2
      #puts "create Eng upload for subject: #{subj.id} #{subj.code}"
        Upload.create!(
          tree_type_code: @curriculumCodeTFV,
          subject_id: subj.id,
          grade_band_id: nil,
          locale_id: @loc_en.id,
          status: 0,
          filename: "#{@ttTFV.code}#{@verTFV.code}#{subj.code.capitalize}AllEngErrors.csv"
        )
      end

    end
  end

  BaseRec::BASE_SUBJECTS.each do |subjCode|
    if @subjectsHashTFV[subjCode]
      #puts "set up library subject for #{subjCode}"
      # Create the English name and abbreviation for the Subjects in the Library.
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_abbr_key(subjCode), @subjectsHashTFV[subjCode.to_sym][:abbr])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_EN, Subject.get_default_name_key(subjCode), @subjectsHashTFV[subjCode.to_sym][:engName])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR

      # Create the Locale's name and abbreviation for the Subjects in the Library.
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, Subject.get_default_abbr_key(subjCode), @subjectsHashTFV[subjCode.to_sym][:locAbbr])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
        rec, status, message =  Translation.find_or_update_translation(BaseRec::LOCALE_TR, Subject.get_default_name_key(subjCode), @subjectsHashTFV[subjCode.to_sym][:locName])
        throw "ERROR updating subject translation: #{message}" if status == BaseRec::REC_ERROR
    end
  end

  @bio = Subject.where(code: 'bio').first

  ###################################################################################
  # seed dimension translations
  # essq,bigidea,pract,miscon
  dim_translations_arr = [
    ['essq', 'K-12 Big Idea', 'K-12 Büyük Fikir'],
    ['bigidea', 'Specific Big Idea', 'Belirli Büyük Fikir'],
    ['pract', 'Associated Practice', 'İlişkili Uygulama'],
    ['miscon', 'Misconception', 'Yanlış kanı'],
  ]
  #TO DO: update on server
  dim_resource_types_arr = [
    ['Second Category', 'İkinci Kategori'],
    ['Correct Understanding', 'Doğru Anlama'],
    ['Possible Source of Misconception', 'Yanlış Anlaşmanın Olası Kaynağı'],
    ['Compiler/Source'],
    ['Primary Research Citation', 'Derleyici / Kaynak'],
    ['Website Link References', 'Web Sitesi Bağlantı Referansları'],
    ['Test Distractor Percent', 'Test Distraktör Yüzdesi'],
    ['Link to Question Item Bank', 'Soru Bağlantısı Bankası'],
    ['Third Category', 'Üçüncü Kategori'],
  ]
  dim_translations_arr.each do |dim|
    dim_name_key = Dimension.get_dim_type_key(
      dim[0],
      @ttTFV.code,
      @verTFV.code
    )
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, dim_name_key, dim[1])
    throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, dim_name_key, dim[2])
    throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
  end
  dim_resource_types_arr.each_with_index do |resource, i|
    resource_name_key = Dimension.get_resource_key(
      Dimension::RESOURCE_TYPES[i],
      @ttTFV.code,
      @verTFV.code
    )
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
    throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, resource_name_key, resource[1])
    throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
  end

  ###################################################################################
  # outcome translations
  outc_resource_types_arr = [
    ["Multi, inter or trans disciplinary Grand Challenges based projects", "Çoklu, disiplinler arası veya disiplinler arası Grand Challenges tabanlı projeler"],
    ["Daily Lesson Plans", "Günlük Ders Planları"],
    ["Textbook and Resource Materials to Use in Class", "Sınıfta Kullanılacak Ders Kitabı ve Kaynak Materyaller"],
    ["Suggested Assessment Resources and Activities", "Önerilen Değerlendirme Kaynakları ve Faaliyetleri"],
    ["Additional Background and Resource Materials for the Teacher", "Öğretmen için Ek Arka Plan ve Kaynak Materyalleri"],
    ["Goal behaviour (What students will do, Practical learning targets)","Hedef davranışı (Öğrenciler ne yapacak, Pratik öğrenme hedefleri)"],
    ["Teacher Support", "Öğretmen Desteği"],
    ["Evidence of Learning", "Öğrenmenin Kanıtı"],
    ["Connections", "Bağlantılar"],
  ]

  outc_resource_types_arr.each_with_index do |resource, i|
    resource_name_key = Outcome.get_resource_key(
      Outcome::RESOURCE_TYPES[i],
      @ttTFV.code,
      @verTFV.code
    )
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, resource_name_key, resource[0])
    throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, resource_name_key, resource[1])
    throw "ERROR updating dimension code translation: #{message}" if status == BaseRec::REC_ERROR
  end

  ###################################################################################
  # create sectors
    # Populate the Sector table and its translations for all  languages

    # Set Subject Abbreviations:
    @sectorsHashTFV = {
      '1': {code: '1', engName: 'Industry 4.0',locName: 'Endüstri 4.0', keyPhrase: 'industry 4.0'},
      '2': {code: '2', engName: 'Sensors and Imaging Technology', locName: 'Sensörler ve Görüntüleme Teknolojisi', keyPhrase: 'sensors and imaging'},
      '3': {code: '3', engName: 'New Food Technologies', locName: 'Yeni Gıda Teknolojileri', keyPhrase: 'food tech'},
      '4': {code: '4', engName: 'Biomedical Technology', locName: 'Biyomedikal Teknoloji', keyPhrase: 'biomedical tech'},
      '5': {code: '5', engName: 'Nanotechnology / Space Technology', locName: 'Nanoteknoloji / Uzay Teknolojisi', keyPhrase: 'nanotechnology'},
      '6': {code: '6', engName: 'Global Warming', locName: 'Küresel Isınma', keyPhrase: 'global warming'},
      '7': {code: '7', engName: 'Internet of Objects / 5G', locName: 'Nesnelerin İnterneti / 5G', keyPhrase: 'internet'},
      '8': {code: '8', engName: 'Population Increase vs Resource Consumption', locName: 'Nüfus artışı karşı Kaynak Tüketimi', keyPhrase: 'population'}
    }

    @sectorsHashTFV.each do |key, sectHash|
      # create the sector
      #puts "create the sector: #{@sectorCodeTFV}, #{sectHash[:code]}"
      sectors = Sector.where(sector_set_code: @sectorCodeTFV, code: sectHash[:code])
      if sectors.count < 1
        sector = Sector.create(
          sector_set_code: @sectorCodeTFV,
          code: sectHash[:code],
          name_key: "sector.#{@sectorCodeTFV}.#{sectHash[:code]}.name",
          base_key: "sector.#{@sectorCodeTFV}.#{sectHash[:code]}",
          key_phrase: sectHash[:keyPhrase]
        )
      else
        sector = sectors.first.update(key_phrase: sectHash[:keyPhrase])
      end
      # create the English translation for the Sector Name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, "sector.#{@sectorCodeTFV}.#{sectHash[:code]}.name", sectHash[:engName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

      # create the Locale's translation for the Sector Name
      rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, "sector.#{@sectorCodeTFV}.#{sectHash[:code]}.name", sectHash[:locName])
      throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    end
    #puts "Sector translations are created for sector set: #{@sectorCodeTFV}"

    @sector1 = Sector.where(name_key: 'sector.future.1.name').first

  end #testing_db_tfv_seed

end # class
