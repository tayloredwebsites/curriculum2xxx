# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

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
  Sector.create(code: '1', translation_key: 'kbe.1.name')
  Sector.create(code: '2', translation_key: 'kbe.2.name')
  Sector.create(code: '3', translation_key: 'kbe.3.name')
  Sector.create(code: '4', translation_key: 'kbe.4.name')
  Sector.create(code: '5', translation_key: 'kbe.5.name')
  Sector.create(code: '6', translation_key: 'kbe.6.name')
  Sector.create(code: '7', translation_key: 'kbe.7.name')
  Sector.create(code: '8', translation_key: 'kbe.8.name')
  Sector.create(code: '9', translation_key: 'kbe.9.name')
  Sector.create(code: '10', translation_key: 'kbe.10.name')
end
throw "Invalid Sector Count" if Sector.count != 10

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.1.name', 'Informacione komunikacione tehnologije (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.2.name', 'Zdravstvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.4.name', 'Proizvodnja energije, prenos, efikasnost')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.5.name', 'Finansije i biznis')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.6.name', 'Umjetnost, zabava i mediji')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.7.name', 'Sport')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.8.name', 'Turizam')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.9.name', 'Poduzetništvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_BS, 'kbe.10.name', 'Savremena poljoprivredna proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.1.name', 'Informacijska komunikacijska tehnologija (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.2.name', 'Zdravstvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.4.name', 'Proizvodnja energije, prijenos, učinkovitost')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.5.name', 'Financije i poslovanje')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.6.name', 'Umjetnost, zabava i mediji')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.7.name', 'Sport')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.8.name', 'Turizam')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.9.name', 'Poduzetništvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_HR, 'kbe.10.name', 'Suvremena poljoprivredna proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.1.name', 'Informacione komunikacione tehnologije (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.2.name', 'Zdravstvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.3.name', 'Tehnologija materijala i visokotehnološka proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.4.name', 'Proizvodnja energije, prenos, efikasnost')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.5.name', 'Finansije i biznis')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.6.name', 'Umjetnost, zabava i mediji')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.7.name', 'Sport')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.8.name', 'Turizam')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.9.name', 'Preduzetništvo')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_SR, 'kbe.10.name', 'Savremena poljoprivredna proizvodnja')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR

rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.1.name', 'Information Communication Technology (ICT)')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.2.name', 'Health')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.3.name', 'Technology of materials and high-tech production')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.4.name', 'Energy production, transmission, efficiency')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.5.name', 'Finance and business')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.6.name', 'Art, entertainment and media')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.7.name', 'Sport')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.8.name', 'Tourism')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.9.name', 'Entrepreneurship')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'kbe.10.name', 'Contemporary agricultural production')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
