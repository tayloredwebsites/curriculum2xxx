# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# create an initial admin user to get things going.
# to do - change this user or deactivate it for production.
if User.count < 1
  User.create(
    email: 'bih@sample.com',
    password: 'password',
    password_confirmation: 'password',
    given_name: 'BiH',
    family_name: 'Web App',
    roles: ['admin'],
    confirmed_at: DateTime.now
  )
end
throw "Invalid User Count" if User.count < 1
@bih = User.where(email: 'bih@sample.com').first

########################################################################
# Note: the code below is copied to test/helpers/seeds_testing_helper.rb

if Version.count < 1
  Version.create(
    code: 'v01'
  )
end
throw "Invalid Version Count" if Version.count > 1
@v01 = Version.first

if TreeType.count < 1
  TreeType.create(
    code: 'OTC'
  )
end
throw "Invalid TreeType Count" if TreeType.count > 1
@otc = TreeType.first

if Locale.count < 1
  Locale.create(
    code: 'bs',
    name: 'bosanski / босански'
  )
  Locale.create(
    code: 'hr',
    name: 'hrvatski'
  )
  Locale.create(
    code: 'sr',
    name: 'српски / srpski'
  )
  loc_en = Locale.create(
    code: 'en',
    name: 'English'
  )
end
throw "Invalid Locale Count" if Locale.count < 1 || Locale.count > 4
@loc_en = Locale.where(code: 'en').first

if GradeBand.count < 1
  GradeBand.create(
    tree_type_id: @otc.id,
    code: '9'
  )
end
if GradeBand.count < 2
  GradeBand.create(
    tree_type_id: @otc.id,
    code: '13'
  )
end
throw "Invalid GradeBand Count" if GradeBand.count != 2
@gb_09 = GradeBand.first
@gb_13 = GradeBand.second

if Subject.count < 1
  Subject.create(
    tree_type_id: @otc.id,
    code: 'Hem'
  )
end
throw "Invalid Subject Count" if Subject.count > 1
@hem = Subject.first

if Upload.count < 1
  Upload.create(
    subject_id: @hem.id,
    grade_band_id: @gb_09.id,
    locale_id: @loc_en.id,
    status: 0,
    filename: 'Hem_09_transl_Eng.csv'
  )
end
if Upload.count < 2
  Upload.create(
    subject_id: @hem.id,
    grade_band_id: @gb_13.id,
    locale_id: @loc_en.id,
    status: 0,
    filename: 'Hem_13_transl_Eng.csv'
  )
end
throw "Invalid Upload Count" if Upload.count != 2
@hem_09 = Upload.first
@hem_13 = Upload.second


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
@sector1 = Sector.find(1)
@sector2 = Sector.find(2)
@sector3 = Sector.find(3)
@sector4 = Sector.find(4)
@sector5 = Sector.find(5)
@sector6 = Sector.find(6)
@sector7 = Sector.find(7)
@sector8 = Sector.find(8)
@sector9 = Sector.find(9)
@sector10 = Sector.find(10)

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.1.name', 'Informacione komunikacione tehnologije (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.2.name', 'Zdravstvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'sector.4.name', 'Proizvodnja energije, prenos, efikasnost')
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

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'sector.1.name', 'Informacijska komunikacijska tehnologija (ICT)')
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

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.1.name', 'Informacione komunikacione tehnologije (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.2.name', 'Zdravstvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.4.name', 'Proizvodnja energije, prenos, efikasnost')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.5.name', 'Finansije i biznis')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.6.name', 'Umjetnost, zabava i mediji')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.7.name', 'Sport')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.8.name', 'Turizam')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.9.name', 'Preduzetništvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'sector.10.name', 'Savremena poljoprivredna proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.1.name', 'Information Communication Technology (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.2.name', 'Health')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.3.name', 'Technology of materials and high-tech production')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.4.name', 'Energy production, transmission, efficiency')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.5.name', 'Finance and business')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.6.name', 'Art, entertainment and media')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.7.name', 'Sport')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.8.name', 'Tourism')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.9.name', 'Entrepreneurship')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'sector.10.name', 'Contemporary agricultural production')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
