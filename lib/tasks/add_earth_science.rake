# add_earth_science.rake
namespace :add_earth_science do

  desc "Add Earth, Space, and Environmental Science as a new subject"
  task create: :environment do
  	if Subject.count == 5
      @tfv = TreeType.where(:code => 'TFV').first
	  	@ear = Subject.create(
		    tree_type_id: @tfv.id,
		    code: 'ear',
		    base_key: 'subject.tfv.v01.ear'
		    )
      puts "created subject: Earth, Space, and Environmental Science"
      locales = Locale.all
      @loc_en = locales.where(:code => 'en').first
      @loc_tr = locales.where(:code => 'tr').first
      puts "retrieved locales"
	  	rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.default.ear.name', 'Earth, Space, & Environmental Science')
  		throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
  		rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'subject.default.ear.abbr', 'Ear')
  		throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
  		rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.default.ear.name', '
  		Dünya, Uzay ve Çevre Bilimi')
  		throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
  		rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_TR, 'subject.default.ear.abbr', 'Dün')
  		throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
      puts "created subject translations"

      grades = GradeBand.all
      @gb_9 = grades[9]
      @gb_10 = grades[10]
      @gb_11 = grades[11]
      @gb_12 = grades[12]
      @gb_hs = [@gb_9, @gb_10, @gb_11, @gb_12]

      @gb_hs.each do |g|
        Upload.create(
          subject_id: @ear.id,
          grade_band_id: g.id,
          locale_id: @loc_en.id,
          status: 0,
          filename: "#{@ear.code.capitalize}#{sprintf('%02d', g.code)}Eng.txt"
        )
        Upload.create(
          subject_id: @ear.id,
          grade_band_id: g.id,
          locale_id: @loc_tr.id,
          status: 0,
          filename: "#{@ear.code.capitalize}#{sprintf('%02d', g.code)}Tur.txt"
        )
      end
      puts "created uploads"
    else
      raise "Incorrect subject count for this task." if Subject.count != 5
    end
  end
end