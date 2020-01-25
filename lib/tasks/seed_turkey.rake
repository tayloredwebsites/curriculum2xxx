# seed_turkey.rake
namespace :seed_turkey do

  task populate: [:create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subject, :create_uploads, :create_sectors]


  ###################################################################################
  desc "create the tree type(s) if missing"
  task create_tree_type: :environment do
    if TreeType.where(code: 'TFV').count < 1
      TreeType.create(
        code: 'TFV',
        hierarchy_codes: 'unit,chapt,attain',
        valid_locales: BaseRec::LOCALE_EN+BaseRec::LOCALE_TR,
        sector_set_code: 'future',
        sector_set_name_key: 'sector_set_future_name',
        curriculum_title_key: 'Turkey STEM Curriculum'
      )
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'TFV').count != 1
    @tfv = TreeType.where(code: 'TFV').first
    puts "@tfv: #{@tfv.inspect}"

    #To Do - Enter translations for hierarchy codes
    #To Do - Enter translations for valid locales?
    #To Do - Enter translations for sector_set_name_key
    #To Do - Enter translations for curriculum_title_key

  end #create_tree_type


  ###################################################################################
  desc "create the load up the locales (from seeds.rb seed file)"
  task load_locales: :environment do
    @loc_tr = Locale.first
    puts "@loc_tr: #{@loc_tr.inspect}"
    @loc_en = Locale.second
    puts "@loc_en: #{@loc_en.inspect}"
    @loc_ar_EG = Locale.third
    puts "@loc_ar_EG: #{@loc_ar_EG.inspect}"
  end #load_locales


  ###################################################################################
  desc "create the admin user(s), if missing"
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
  desc "create any missing grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    %w(k 1 2 3 4 5 6 7 8 9 10 11 12).each do |g|
      gf = (g == 'k') ? 0 : g
      begin
        if GradeBand.where(tree_type_id: @tfv.id, code: g).count < 0
          GradeBand.create(
            tree_type_id: @tfv.id,
            code: g,
            sort_order: "%02d" % [gf]
          )
        end
      rescue
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
    @gb_hs = [@gb_9, @gb_10, @gb_11, @gb_12]
    @gb_mid = [@gb_5, @gb_6, @gb_7, @gb_8]
    @gb_el = [@gb_1, @gb_2, @gb_3, @gb_4]
    # puts "grades: #{grades.pluck(:id)}"
  end #create_grade_bands


  ###################################################################################
  desc "create any missing subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    if Subject.where(tree_type_id: @tfv.id, code: 'bio')
      Subject.create(
        tree_type_id: @tfv.id,
        code: 'bio',
        base_key: 'subject.bio'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'che')
      Subject.create(
        tree_type_id: @tfv.id,
        code: 'che',
        base_key: 'subject.che'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'mat')
      Subject.create(
        tree_type_id: @tfv.id,
        code: 'mat',
        base_key: 'subject.mat'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'phy')
      Subject.create(
        tree_type_id: @tfv.id,
        code: 'phy',
        base_key: 'subject.phy'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'sci')
      Subject.create(
        tree_type_id: @tfv.id,
        code: 'sci',
        base_key: 'subject.sci'
      )
    end
    if Subject.where(tree_type_id: @tfv.id, code: 'ear')
      Subject.create(
        tree_type_id: @tfv.id,
        code: 'ear',
        base_key: 'subject.ear'
      )
    end
    @bio = Subject.where(tree_type_id: @tfv.id, code: 'bio').first
    @che = Subject.where(tree_type_id: @tfv.id, code: 'che').first
    @mat = Subject.where(tree_type_id: @tfv.id, code: 'mat').first
    @phy = Subject.where(tree_type_id: @tfv.id, code: 'phy').first
    @sci = Subject.where(tree_type_id: @tfv.id, code: 'sci').first
    @ear = Subject.where(tree_type_id: @tfv.id, code: 'ear').first
    @subjects = [@bio, @che, @mat, @phy, @ear, @sci]
    @subj_hs = [@bio, @che, @mat, @phy, @ear]
    @subj_mid = [@sci, @mat]
    @subj_el = [@sci, @mat]

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.bio.name', 'Biology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.bio.abbr', 'Bio')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.bio.name', 'Biyoloji')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.bio.abbr', 'Biy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.che.name', 'Chemistry')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.che.abbr', 'Chem')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.che.name', 'Kimya')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.che.abbr', 'Kim')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.mat.name', 'Mathematics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.mat.abbr', 'Math')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.mat.name', 'Matematik')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.mat.abbr', 'Mat')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.phy.name', 'Physics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.phy.abbr', 'Phy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.phy.name', 'Fizik')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.phy.abbr', 'Fiz')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.sci.name', 'Science')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.sci.abbr', 'Sci')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.sci.name', 'Bilim')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.sci.abbr', 'Bil')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.ear.name', 'Earth, Space, & Environmental Science')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.tfv.ear.abbr', 'Ear')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.ear.name', '
    Dünya, Uzay ve Çevre Bilimi')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.tfv.ear.abbr', 'Dün')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
  end #create_subjects


  ###################################################################################
  desc "create any missing upload control files"
  task create_uploads: :environment do
    [@gb_1, @gb_2].each do |g|
      [@mat].each do |s|
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
    [@gb_3, @gb_4].each do |g|
      @subj_el.each do |s|
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
    @gb_mid.each do |g|
      @subj_mid.each do |s|
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
    @gb_hs.each do |g|
      @subj_hs.each do |s|
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
          )
        end
        if upload.where(tree_type_code: 'tfv',
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
            filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
          )
        end
      end
    end
  end #create_uploads


  ###################################################################################
  desc "create any missing sectors (e.g. Grand Challenges, Future Sectors, ...)"
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
  end

end


