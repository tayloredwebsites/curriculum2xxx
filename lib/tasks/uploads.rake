# uploads.rake
namespace :uploads do

  desc "Add uploads to the uploads page"
  task add: :environment do
  	if Upload.count < 68
  		@loc_en = Locale.where(:code => 'en').first
  		@loc_tr = Locale.where(:code => 'tr').first
	  	@sci = Subject.where(:code => 'sci').first
	  	@mat = Subject.where(:code => 'mat').first
		  grades = GradeBand.all
			@gb_1 = grades[1]
			@gb_2 = grades[2]
			@gb_3 = grades[3]
			@gb_4 = grades[4]
			@gb_5 = grades[5]
			@gb_6 = grades[6]
			@gb_7 = grades[7]
			@gb_8 = grades[8]
			@mat_gb = [@gb_1, @gb_2, @gb_5, @gb_6, @gb_7, @gb_8]
			@shared_gb = [@gb_3, @gb_4]

			@mat_gb.each do |g|
		    [@mat].each do |s|
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
			@shared_gb.each do |g|
		    [@mat, @sci].each do |s|
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
		end #check there are not yet 68 Uploads.
		throw "Invalid Upload Count" if Upload.count != 68
  end

  desc "Run after adding uploads to the uploads page. Resets sort order for all subjects to match grade bands"
  task reset_sequence: :environment do
  	listing = Tree.order("trees.grade_band_id, trees.sequence_order, code").where(:depth => 3)
  	listing.each_with_index do |t, i|
  		t.sequence_order = i
  		t.save
  	end
  end
end


