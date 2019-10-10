# set_grade_sort_order.rake
namespace :set_grade_sort_order do

  desc "set the sort_order field for the grade_band table (if not running db:seed)"
  task run: :environment do

    GradeBand.all.each do |gb|
      case gb.code
      when 'k'
        gb.sort_order = 0
      else
        begin
          gb.sort_order = Integer(gb.code)
        rescue
          gb.sort_order = 99
        end
      end
      gb.save
    end
  end

end
