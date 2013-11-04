namespace :states do
  desc "Importing states from states-list.txt file"
  task :import => :environment do
    puts "-----------------------------------------------------------------"
    puts "States importing started..."
    path = File.join(Rails.root, "log", "states-importing.log")
    File.delete(path) if File.exist?(path)
    import_log = Logger.new(path)
    import_log.level = Logger::DEBUG
    import_log.debug "-----------------------------------------------------------------"
    import_log.debug "States importing started.."
    File.open(Rails.configuration.state_path, "r") do |file|
      begin
        i = 0
        file.each do |f|
          str = f.split('=')
          country = str[0].match(/\[.*\]/)
          country_name = country.to_s.split(/[\[\]']/).last.strip
          puts "|-> #{country_name}"
          import_log.debug "|-> #{country_name}"
          unless ["United States", "Canada"].include?(country_name)
            country = Country.where(:printable_name => /.*#{country_name}.*/).first
            if country.present?
              str[1].gsub!("';\n", '')
              str[1].gsub!("'|", '')
              if country_name != 'United Kingdom'
                str[1].strip!
                new_str = str[1].split('||').last
                country.states.destroy_all
                states = new_str.split('|')
                states.each do |st|
                  country.states.create!(:name => st.strip)
                  i+=1
                  puts " |-> #{st}"
                  import_log.debug " |-> #{st}"
                end if states.present?
              else
                country.states.destroy_all
                str[1].split('||').each do |newstr|
                  newstr.split('|').drop(1).each do |state|
                    country.states.create!(:name => state.strip)
                    i+=1
                    puts " |-> #{state}"
                    import_log.debug " |-> #{state}"
                  end
                end
              end
            end
          end
        end if file.present?
        puts "Total number of states imported: #{i}"
        import_log.debug "Total number of states imported: #{i}"
      rescue Exception => e
        puts "Error: #{e.message}"
        import_log.debug "Error: #{e.message}"
      end
    end if File.exist?(Rails.configuration.state_path)
    puts "States importing completed."
    puts "-----------------------------------------------------------------"
    import_log.debug "States importing completed."
    import_log.debug "-----------------------------------------------------------------"
  end
end