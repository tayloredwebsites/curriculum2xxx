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
@v01 = Version.last

if Locale.count < 3
  Locale.create(
    code: 'tr',
    name: 'Türkçe'
  )
  loc_en = Locale.create(
    code: 'en',
    name: 'English'
  )
  loc_ar_EG = Locale.create(
    code: 'ar_EG',
    name: 'العربية (مصر)'
  )
end
puts "Locales: #{Locale.all.inspect}"
throw "Invalid Locale Count" if Locale.count != 3

# Titles of (Default) English Dimension Pages
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'trees.bigidea.title', 'Big Ideas')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'trees.miscon.title', 'Misconceptions')
throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR



