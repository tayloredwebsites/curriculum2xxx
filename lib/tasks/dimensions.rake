namespace :dimensions do
  desc "set the subject_code field for Dimensions (if not already set), from the subject_id"
  task set_subject_codes: :environment do

  	dimensions = Dimension.where(subject_code: "")
  	dimensions.each do |d|
  		begin
        code = Subject.find(d.subject_id).code
        d.subject_code = code
        d.save!
         puts "Saved subject code '#{d.subject_code}' for dimension id: #{d.id}"
  		rescue
        puts "Failed to save subject code for dimension id: #{d.id}"
  		end
  	end

  end #task set_subject_codes: :environment do

end