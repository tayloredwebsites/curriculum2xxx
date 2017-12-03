# translation_table.rake
namespace :translation_table do

  desc "load Translation tables into database from yml file"
  task :load_db do

    require 'yaml'

    if ARGV[1]
      filename = Rails.root.join( ARGV[1])
      puts("Loading file: #{filename}")
      tableIn = YAML.load_file(filename)
      puts "tableIn.length = #{tableIn.length}"
      if tableIn.length > 1
        puts "ERROR: Can only process one language at a time (and language must be first key)"
      else
        locale, v = tableIn.first
        entry_loop(locale, '', v)
      end
    else
      puts 'Missing filename argument'
    end
    puts "Done"

  end # load_db

  def entry_loop(locale, k, v)
    if v.is_a?(::Hash)
      v.each do |k2, v2|
        # if first key, don't append prior key
        set_key = (k.blank? ? k2 : "#{k}.#{k2}")
        if v2.is_a?(::Hash)
          entry_loop(locale, set_key, v2)
        else
          process_entry(locale, set_key, v2)
        end
      end
    else
      puts "v is not a hash ???"
      process_entry(locale, k, v)
    end
  end

  # write the new translation into the Translation table in the database
  def process_entry(locale, k, v)
    puts "language: #{locale}, key: #{k}, value: #{v}"
    recs = Translation.where( locale: locale, key: k)
    if recs.count == 0
      Translation.create(locale: locale, key: k, value: v)
    else
      puts "already exists: #{locale}, #{key}"
    end
  end

end # translation_table
