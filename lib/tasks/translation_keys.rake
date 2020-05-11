# translation_keys.rake
# This was used to migrate the data to a new standardized translation key
#     which now comes from the model.
namespace :translation_keys do
  desc "Fix subject name and abbr translation keys in both Subject and Translation Records"
  task fix_subjects: :environment do
    subjects = Subject.all
    subject_codes = subjects.pluck('code').uniq
    BaseRec::BASE_SUBJECTS.map {|code| subject_codes << code if !subject_codes.include?(code) }

    #fix translation keys for:
    # - Curriculum specific subject name
    # - Curriculum specific subject abbreviation
    # Then fix subject base keys
    subjects.each do |s|
      names = Translation.where(:key => "#{s.base_key}.name")
      abbrs = Translation.where(:key => "#{s.base_key}.abbr")
      if names.count == 0
        puts "missing name translations for #{s.code} Subject: #{s.id}"
      elsif names.count == 1
        puts "missing locale name translation for #{s.code} Subject: #{s.id}"
      end
      if abbrs.count == 0
        puts "missing abbr translations for #{s.code} Subject: #{s.id}"
      elsif abbrs.count == 1
        puts "missing locale abbr translation for #{s.code} Subject: #{s.id}"
      end
      names.each do |rec|
        puts "Updating translation #{rec.id}: '#{rec.value}' with key: #{s.get_versioned_name_key}"
        rec.update(key: s.get_versioned_name_key)
      end
      abbrs.each do |rec|
        puts "Updating translation #{rec.id}: '#{rec.value}' with key: #{s.get_versioned_abbr_key}"
        rec.update(key: s.get_versioned_abbr_key)
      end
      puts "[Subject #{s.id}] Updating subject base key from '#{s.base_key}' to #{s.build_base_key}"
      s.update(base_key: s.build_base_key)
    end

    #fix translation keys for:
    # - Default subject name for subject code from BaseRec
    # - Default subject abbreviation for subject code from BaseRec
    subject_codes.each do |code|
      names = Translation.where(:key => "subject.base.#{code}.name")
      abbrs = Translation.where(:key => "subject.base.#{code}.abbr")
      if names.count == 0
        puts "missing default name translations for code: #{code}"
      elsif names.count == 1
        puts "in at least one locale, missing a default name translation for code: #{code}"
      end
      if abbrs.count == 0
        puts "missing default abbr translations for code: #{code}"
      elsif abbrs.count == 1
        puts "in at least one locale, missing a default abbr translation for code: #{code}"
      end
      names.each do |rec|
        puts "Updating translation #{rec.id}: '#{rec.value}' with key: #{Subject.get_default_name_key(code)}"
        rec.update(key: Subject.get_default_name_key(code))
      end
      abbrs.each do |rec|
        puts "Updating translation #{rec.id}: '#{rec.value}' with key: #{Subject.get_default_abbr_key(code)}"
        rec.update(key: Subject.get_default_abbr_key(code))
      end
    end

  end # task fix_subjects

  desc "Add versioned name translations for tfv.v02 subjects"
  task subject_names_v02: :environment do
    subject_lookup_en = {
      bio: "Biology",
      che: "Chemistry",
      mat: "Mathematics",
      sci: "Science",
      phy: "Physics",
      ear: "Earth Science",
      tech: "Tech Engineering",
    }
    Subject.where(tree_type_id: 2).each do |s|
      key = s.get_versioned_name_key
      s_name = subject_lookup_en[:"#{s.code}"]
      puts "Updating versioned translation, #{key}: #{s_name}"
      Translation.find_or_update_translation(
        "en",
        key,
        s_name
      )
    end
  end #task subject_names_v02: :environment do
end