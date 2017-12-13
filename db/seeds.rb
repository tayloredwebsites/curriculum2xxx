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
v01 = Version.first
puts "v01: #{v01.inspect}"

if TreeType.count < 1
  TreeType.create(
    code: 'OTC'
  )
end
throw "Invalid TreeType Count" if TreeType.count > 1
otc = TreeType.first
puts "otc: #{otc.inspect}"

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
loc_en = Locale.where(code: 'en').first
puts "loc_en: #{loc_en.inspect}"

if GradeBand.count < 1
  GradeBand.create(
    tree_type_id: otc.id,
    code: '09'
  )
end
throw "Invalid GradeBand Count" if GradeBand.count > 1
gb_09 = GradeBand.first
puts "gb_09: #{gb_09.inspect}"

if Subject.count < 1
  Subject.create(
    tree_type_id: otc.id,
    code: 'Hem'
  )
end
throw "Invalid Subject Count" if Subject.count > 1
hem = Subject.first
puts "hem: #{hem.inspect}"

if Upload.count < 1
  Upload.create(
    subject_id: hem.id,
    grade_band_id: gb_09.id,
    locale_id: loc_en.id,
    status: 0
  )
end
throw "Invalid Upload Count" if Upload.count > 1
hem_09 = Upload.first
puts "hem_09: #{hem_09.inspect}"
