namespace :content do
  namespace :sections do 
    desc "import section configuration"
    task :import => :environment do
      # ApplicationModel.connection.execute("TRUNCATE sections")
      ApplicationModel.connection.execute("TRUNCATE agencies_sections")
      ApplicationModel.connection.execute("TRUNCATE section_assignments")
      
      sections = YAML::load(File.open("#{RAILS_ROOT}/data/sections.yml"))
      sections.each do |attributes|
        section = Section.find_or_create_by_id(attributes['id'])
        section.update_attributes!(attributes.merge(:relevant_cfr_sections => nil, :agencies => []))
      end
      
      FasterCSV.foreach("data/sections_cfr.csv", :headers => :first_row) do |line|
        section_data = line.to_hash
        section = Section.find_by_title!(line['section_title'])
        
        if line["cfr"] =~ /^(\d+) CFR /
          title, part_string = line["cfr"].split(/ CFR /)
          parts = part_string.split(/\s*,\s*/)
          
          new_cfr_strings = parts.map {|part| "#{title} CFR #{part.strip}" }
          section.relevant_cfr_sections = ([section.relevant_cfr_sections] + new_cfr_strings).compact.join("\n")
          section.save!
        else
          puts "Invalid CFR line: '#{line["cfr"]}'"
        end
      end
      
      FasterCSV.foreach("data/sections_agencies.csv", :headers => :first_row) do |line|
        agency = Agency.find_by_name!(line['agency_name'].strip)
        %w(section_1_title section_2_title section_3_title).each do |name|
          if line[name].present?
            section = Section.find_by_title!(line[name])
            section.agencies << agency
          end
        end
      end
    end
  end
end