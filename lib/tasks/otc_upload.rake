# otc_upload.rake
namespace :otc do

  desc "upload OTC from spreadsheet"
  task :upload do

    if ARGV[1]
      filename = Rails.root.join( ARGV[1])
      puts("Loading file: #{filename}")
      CSV.foreach(filename) do |row|
        entry_loop(row)
      end
    else
      puts 'Missing filename argument'
    end
    puts "Done"

  end # load_db

  def entry_loop(row)
    # if v.is_a?(::Hash)
    #   v.each do |k2, v2|
    #     # if first key, don't append prior key
    #     set_key = (k.blank? ? k2 : "#{k}.#{k2}")
    #     if v2.is_a?(::Hash)
    #       entry_loop(locale, set_key, v2)
    #     else
    #       process_entry(locale, set_key, v2)
    #     end
    #   end
    # else
    #   puts "v is not a hash ???"
    #   process_entry(locale, k, v)
    # end
  end

  # # write the new translation into the Translation table in the database
  # def process_entry(locale, k, v)
  #   puts "language: #{locale}, key: #{k}, value: #{v}"
  #   recs = Translation.where( locale: locale, key: k)
  #   if recs.count == 0
  #     Translation.create(locale: locale, key: k, value: v)
  #   else
  #     puts "already exists: #{locale}, #{key}"
  #   end
  # end

end # translation_table
