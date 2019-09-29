# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# create an initial admin user to get things going.
# to do - turn off admin flag for production.
if User.count < 1
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
    confirmed_at: DateTime.now
  )
end
throw "Invalid User Count" if User.count < 1
@bih = User.where(email: 'tfv@sample.com').first

########################################################################
# Note: the code below is copied to test/helpers/seeds_testing_helper.rb

if Version.count < 1
  Version.create(
    code: 'v01'
  )
end
throw "Invalid Version Count" if Version.count > 1
@v01 = Version.last

if TreeType.count < 1
  TreeType.create(
    code: 'TFV'
  )
end
throw "Invalid TreeType Count" if TreeType.count > 1
@tfv = TreeType.last
puts "@tfv: #{@tfv.inspect}"

if Locale.count < 1
  Locale.create(
    code: 'tr',
    name: 'Türk'
  )
  loc_en = Locale.create(
    code: 'en',
    name: 'English'
  )
end
puts "Locales: #{Locale.all.inspect}"
throw "Invalid Locale Count" if Locale.count != 2
@loc_tr = Locale.first
@loc_en = Locale.second

if GradeBand.count < 13
  %w(k 1 2 3 4 5 6 7 8 9 10 11 12).each do |g|
    begin
      GradeBand.create(
        tree_type_id: @tfv.id,
        code: g
      )
    rescue
    end
  end
end

throw "Invalid GradeBand Count" if GradeBand.count != 13
grades = GradeBand.all
@gb_k = grades[0]
@gb_1 = grades[1]
@gb_2 = grades[2]
@gb_3 = grades[3]
@gb_4 = grades[4]
@gb_5 = grades[5]
@gb_6 = grades[6]
@gb_7 = grades[7]
@gb_8 = grades[8]
@gb_9 = grades[9]
@gb_10 = grades[10]
@gb_11 = grades[11]
@gb_12 = grades[12]
@grade_bands = GradeBand.all
@gb_hs = [@gb_9, @gb_10, @gb_11, @gb_12]
@gb_mid = [@gb_5, @gb_6, @gb_7, @gb_8]
puts "grades: #{grades.pluck(:id)}"


if Subject.count < 5
  Subject.create(
    tree_type_id: @tfv.id,
    code: 'bio',
    base_key: 'subject.bio'
  )
  Subject.create(
    tree_type_id: @tfv.id,
    code: 'che',
    base_key: 'subject.che'
  )
  Subject.create(
    tree_type_id: @tfv.id,
    code: 'mat',
    base_key: 'subject.mat'
  )
  Subject.create(
    tree_type_id: @tfv.id,
    code: 'phy',
    base_key: 'subject.phy'
  )
  Subject.create(
    tree_type_id: @tfv.id,
    code: 'sci',
    base_key: 'subject.sci'
  )
end
throw "Invalid Subject Count" if Subject.count != 5
@bio = Subject.first
@che = Subject.second
@mat = Subject.third
@phy = Subject.fourth
@sci = Subject.fifth
@subjects = Subject.all
@subj_hs = [@bio, @che, @mat, @phy]
@subj_mid = [@sci]

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.bio.name', 'Biology')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.bio.abbr', 'Bio')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.bio.name', 'Biyoloji')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.bio.abbr', 'Biy')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.che.name', 'Chemistry')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.che.abbr', 'Chem')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.che.name', 'Kimya')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.che.abbr', 'Kim')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.mat.name', 'Mathematics')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.mat.abbr', 'Math')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.mat.name', 'Matematik')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.mat.abbr', 'Mat')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.phy.name', 'Physics')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.phy.abbr', 'Phy')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.phy.name', 'Fizik')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.phy.abbr', 'Fiz')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.sci.name', 'Science')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.sci.abbr', 'Sci')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.sci.name', 'Bilim')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.sci.abbr', 'Bil')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR


# high school subjects:

if Upload.count != 40
  @gb_hs.each do |g|
    @subj_hs.each do |s|
      Upload.create(
        subject_id: s.id,
        grade_band_id: g.id,
        locale_id: @loc_en.id,
        status: 0,
        filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
      )
      Upload.create(
        subject_id: s.id,
        grade_band_id: g.id,
        locale_id: @loc_tr.id,
        status: 0,
        filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
      )
    end
  end
  @gb_mid.each do |g|
    @subj_mid.each do |s|
      Upload.create(
        subject_id: s.id,
        grade_band_id: g.id,
        locale_id: @loc_en.id,
        status: 0,
        filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
      )
      Upload.create(
        subject_id: s.id,
        grade_band_id: g.id,
        locale_id: @loc_tr.id,
        status: 0,
        filename: "#{s.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
      )
    end
  end
end
# valid count:
#   32 high school (4 grades * 4 subjects * 2 languages)
#   + 8 middle school (4 grades * 1 subject * 2 languages)
#   = 40 valid uploads
throw "Invalid Upload Count" if Upload.count != 40


################################
# Populate the Sector table and its translations for all  languages
if Sector.count > 0 && Sector.count != 8
  throw "Invalid KBE Sector count #{Sector.count}"
elsif Sector.count == 8
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
end
throw "Invalid Sector Count" if Sector.count != 8
@sector1 = Sector.where(name_key: 'sector.1.name').first
@sector2 = Sector.where(name_key: 'sector.2.name').first
@sector3 = Sector.where(name_key: 'sector.3.name').first
@sector4 = Sector.where(name_key: 'sector.4.name').first
@sector5 = Sector.where(name_key: 'sector.5.name').first
@sector6 = Sector.where(name_key: 'sector.6.name').first
@sector7 = Sector.where(name_key: 'sector.7.name').first
@sector8 = Sector.where(name_key: 'sector.8.name').first


rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.1.name', 'Industry 4.0')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.2.name', 'Sensors and Imaging Technology')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.3.name', 'New Food Technologies')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.4.name', 'Biomedical Technology')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.5.name', 'Nanotechnology / Space Technology')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.6.name', 'Global Warming')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.7.name', 'Internet of Objects / 5G')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.8.name', 'Population Increase vs Resource Consumption')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.1.name', 'Endüstri 4.0')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.2.name', 'Sensörler ve Görüntüleme Teknolojisi')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.3.name', 'Yeni Gıda Teknolojileri')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.4.name', 'Biyomedikal Teknoloji')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.5.name', 'Nanoteknoloji / Uzay Teknolojisi')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.6.name', 'Küresel Isınma')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.7.name', 'Nesnelerin İnterneti / 5G')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'sector.8.name', 'Nüfus artışı karşı Kaynak Tüketimi')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
