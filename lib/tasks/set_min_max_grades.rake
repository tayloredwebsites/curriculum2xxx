# Sets Min and Max grades for the subject records for pre-existing subjects, grade bands and dimensions
namespace :set_min_max_grades do

  desc "set the min_grade and max_grade field for Dimensions, Subjects, and Gradebands with min and max grades set to 999"
  task run: :environment do
    subjects = Subject.all;
    gbs = GradeBand.all;
    dims = Dimension.all;

    # Add code for gradebands covering more than one grade,
    # or gradebands with a non-integer code
    gb_grade_map = {
    	k: {min: 0, max: 0},
    	fresh: {min: 13, max: 13},
    	soph: {min: 14, max: 14},
    	junior: {min: 15, max: 15},
    	senior: {min: 16, max: 16},
    }

    gbs.each do |gb|
      if gb.min_grade == 999
	      gb_grades = gb_grade_map[gb[:code]] ? gb_grade_map[gb[:code]] : {min: gb[:code], max: gb[:code]}
	      gb.min_grade = gb_grades[:min]
	      gb.max_grade = gb_grades[:max]
	      gb.save!
	      puts "Updated GradeBand #{gb[:code]}: min_grade = #{gb[:min_grade]} and max_grade = #{gb[:max_grade]}"
      end
    end

    # If any curriculum tree items reference this subject,
    # change the min/max grades to reflect existing curriculum
    # Max/min grades should be set for gradebands before this is attempted.
    subjects.each do |s|
      subj_gbs = GradeBand.where(:id => Tree.where(:subject_id => s.id).pluck("grade_band_id").uniq)
      min_grades = subj_gbs.order("min_grade asc").pluck("min_grade").uniq
      max_grades = subj_gbs.order("max_grade desc").pluck("max_grade").uniq
      if min_grades.length > 0 && max_grades.length > 0
      	s.min_grade = min_grades[0]
      	s.max_grade = max_grades[0]
      	s.save!
      	puts "Updated Subject #{s[:code]}: min_grade = #{s[:min_grade]} and max_grade = #{s[:max_grade]}"
      end
    end


    # Set default min and max grades for Dimensions to match their subject.
    # Note: these values may be adjusted by users in the app to be more or less
    #       restrictive than the values on the subject. Therefore, only set
    #       values for dimensions with a min and max grade of 999
    dims.each do |d|
      if d.min_grade == 999
        begin
          dim_subj = Subject.find(d.subject_id)
          d.min_grade = dim_subj.min_grade
          d.max_grade = dim_subj.max_grade
          d.save!
          puts "Updated Dimension #{d[:code]}: min_grade = #{d[:min_grade]} and max_grade = #{d[:max_grade]}"
        rescue
          puts "Could not update Dimension #{d[:code]}"
        end
      end
    end

  end
end
