# seed_eg_stem.rake
namespace :seed_eg_stem do

  task populate: [:create_tree_type, :load_locales, :create_admin_user, :create_grade_bands, :create_subjects, :create_uploads, :create_sectors]


  ###################################################################################
  desc "create the tree type(s)"
  task create_tree_type: :environment do
    myTreeType = TreeType.where(code: 'EGSTEM')
    myTreeTypeValues = {
      code: 'EGSTEM',
      hierarchy_codes: 'sem,unit,lo',
      valid_locales: BaseRec::LOCALE_EN,
      sector_set_code: 'gr_chall',
      sector_set_name_key: 'sector_set_gr_chal_name',
      curriculum_title_key: 'curriculum_title_egstem' #'Egypt STEM Teacher Prep Curriculum'
    }
    if myTreeType.count < 1
      TreeType.create(myTreeTypeValues)
    else
      TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'EGSTEM').count != 1
    @egstem = TreeType.where(code: 'EGSTEM').first

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstem.hierarchy.sem', 'Semester')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstem.hierarchy.unit', 'Unit of Study')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.egstem.hierarchy.lo', 'Learning Outcome')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #To Do - Enter translations for sector_set_name_key

    #To Do - Enter translations for curriculum_title_key

    puts "Curriculum (Tree Type) is created for EGSTEM"
    puts "  Curriculum: #{@egstem.code} with hierarchy: #{@egstem.hierarchy_codes}"
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
    if User.where(email: 'egstem@sample.com').count < 1
      User.create(
        email: 'egstem@sample.com',
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
    @user = User.where(email: 'egstem@sample.com').first
    puts "admin user is created for EGSTEM"
  end #create_admin_user


  ###################################################################################
  desc "create the grade bands for this tree type (curriculum)"
  task create_grade_bands: :environment do
    if GradeBand.count < 13
      %w(10 11 12).each do |g|
        begin
          if GradeBand.where(tree_type_id: @egstem.id, code: g).count < 0
            GradeBand.create(
              tree_type_id: @egstem.id,
              code: g,
              sort_order: "%02d" % [gf]
            )
          end
        rescue
        end
      end

      @gb_10 = GradeBand.where(tree_type_id: @egstem.id, code: '10').first
      @gb_11 = GradeBand.where(tree_type_id: @egstem.id, code: '11').first
      @gb_12 = GradeBand.where(tree_type_id: @egstem.id, code: '12').first
      @gb_hs = [@gb_9, @gb_10, @gb_11, @gb_12]
    end
    puts "grade bands are created for EGSTEM"
  end #create_grade_bands


  ###################################################################################
  desc "create the subjects for this tree type (curriculum)"
  task create_subjects: :environment do
    if Subject.where(tree_type_id: @egstem.id, code: 'bio')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'bio',
        base_key: 'subject.egstem.bio'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'cap')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'cap',
        base_key: 'subject.egstem.cap'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'che')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'che',
        base_key: 'subject.egstem.che'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'engl')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'engl',
        base_key: 'subject.egstem.engl'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'edu')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'edu',
        base_key: 'subject.egstem.edu'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'geo')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'geo',
        base_key: 'subject.egstem.geo'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'mat')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'mat',
        base_key: 'subject.egstem.mat'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'mec')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'mec',
        base_key: 'subject.egstem.mec'
      )
    end
    if Subject.where(tree_type_id: @egstem.id, code: 'phy')
      Subject.create(
        tree_type_id: @egstem.id,
        code: 'phy',
        base_key: 'subject.egstem.phy'
      )
    end
    puts "Subjects are created for EGSTEM"

    #bio
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.bio.name', 'Biology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.bio.abbr', 'Bio')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #cap
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.bio.name', 'Capstones')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.bio.abbr', 'Cap')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #che
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.name', 'Chemistry')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.abbr', 'Chem')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #engl
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.name', 'English')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.abbr', 'Engl')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #edu
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.name', 'Education')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.abbr', 'Edu')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #geo
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.name', 'Geology')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.che.abbr', 'Geo')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #mat
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.mat.name', 'Mathematics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.mat.abbr', 'Math')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #mec
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.mat.name', 'Mechanics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.mat.abbr', 'Mec')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    #phy
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.phy.name', 'Physics')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.egstem.phy.abbr', 'Phy')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "subject translations are created for EGSTEM"
  end #create_subjects


  ###################################################################################
  desc "create the upload control files"
  task create_uploads: :environment do
    # code here
    puts "No uploads for EGSTEM"
  end #create_uploads


  ###################################################################################
  desc "create the sectors (e.g. Grand Challenges, Future Sectors, ...)"
  task create_sectors: :environment do
    if Sector.where(sector_set_code: 'gr_chall', code: '1').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '1', name_key: 'sector.egstem.1.name', base_key: 'sector.egstem.1')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '2').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '2', name_key: 'sector.egstem.2.name', base_key: 'sector.egstem.2')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '3').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '3', name_key: 'sector.egstem.3.name', base_key: 'sector.egstem.3')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '4').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '4', name_key: 'sector.egstem.4.name', base_key: 'sector.egstem.4')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '5').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '5', name_key: 'sector.egstem.5.name', base_key: 'sector.egstem.5')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '6').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '6', name_key: 'sector.egstem.6.name', base_key: 'sector.egstem.6')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '7').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '7', name_key: 'sector.egstem.7.name', base_key: 'sector.egstem.7')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '8').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '8', name_key: 'sector.egstem.8.name', base_key: 'sector.egstem.8')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '9').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '9', name_key: 'sector.egstem.9.name', base_key: 'sector.egstem.9')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '10').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '10', name_key: 'sector.egstem.10.name', base_key: 'sector.egstem.10')
    end
    if Sector.where(sector_set_code: 'gr_chall', code: '11').count < 1
      Sector.create(sector_set_code: 'gr_chall', code: '11', name_key: 'sector.egstem.11.name', base_key: 'sector.egstem.11')
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


    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.1.name', 'Deal with population growth and its consequences.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.2.name', 'Improve the use of alternative energies.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.3.name', 'Deal with urban congestion and its consequences.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.4.name', 'Improve the scientific and technological environment for all.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.5.name', 'Work to eradicate public health issues/disease.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.6.name', 'Improve uses of arid areas.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.7.name', 'Manage and increase the sources of clean water.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.8.name', 'Increase the industrial and agricultural bases of Egypt.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.9.name', 'Address and reduce pollution fouling our air, water and soil.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.10.name', 'Recycle garbage and waste for economic and environmental purposes.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.egstem.11.name', 'Reduce and adapt to the effect of climate change.')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

    puts "Sector translations are created for EGSTEM"
  end #create_sectors

end
