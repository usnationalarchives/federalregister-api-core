def clean_url(url)
  if url =~ /^[a-z]+:\/\//
    url
  else
    "http://#{url}"
  end
end

def normalize_name(name)
  name.sub!(/^U.S. /, '') # remove U.S. at beginning
  name.sub!(/&/, 'and')
  
  # fix spelling
  name.sub!(/Departnent/, 'Department')
  name.sub!(/Afffairs/, 'Affairs')
  
  # remove parentheticals
  name.sub!(/\(.*\)/, '')
  name.sub!(/\[.*\]/, '')
  
  # remove garbage at the end
  name.sub!(/\W+$/, '')
  
  if name !~ /[a-z]/ || /[A-Z]{5,}/ # ie all uppercase
    name.downcase.capitalize_most_words
  else
    name
  end
end

namespace :data do
  namespace :import do
    desc "Import entries MODS file(s) into the database"
    task :entries => :environment do
      date = ENV['DATE_TO_IMPORT'].blank? ? Date.today : Date.parse(ENV['DATE_TO_IMPORT'])
      
      file_name = "#{RAILS_ROOT}/data/mods/#{date.to_s(:db)}.xml"
      doc = Nokogiri::XML(open(file_name))
      
      publication_date = doc.css('dateIssued').first.try(:content)
      if !publication_date
        puts "skipping #{file_name} [no dateIssued!]"
        next
      end
      
      volume = doc.css('volume').first.try(:content)
      
      puts "importing #{publication_date}..."
    
      doc.css('relatedItem').each do |entry_node|
        document_number = entry_node.css('accessId').first.try(:content)
        next if document_number.nil?
        
        title = entry_node.css('title').first.try(:content)
        next if title.blank? || title == 'Contents' || title == 'Reader Aids'
        
        
        entry = Entry.find_or_create_by_document_number(document_number)
        
        entry.document_number  = document_number
        entry.publication_date = publication_date
        entry.title            = title
        entry.volume           = volume
        
        entry.toc_subject = entry_node.css('tocSubject1').first.try(:content)
        
        entry.citation = entry_node.css('identifier[type="preferred citation"]').first.try(:content)
        regulation_id_number = entry_node.css('identifier[type="regulation ID number"]').first.try(:content)
        entry.regulation_id_number = regulation_id_number.sub!(/RIN /, '') if regulation_id_number.present?
        entry.start_page = entry_node.css('extent[unit="pages"] start').first.try(:content)
        entry.end_page = entry_node.css('extent[unit="pages"] end').first.try(:content)
        
        %w(effectiveDate commentDate).each do |date_tag_name|
          date = entry_node.css(date_tag_name).first.try(:content)
          if date
            type = date_tag_name.capitalize_first
            entry.referenced_dates.find_or_create_by_date_and_date_type(date, type)
          end
        end
        
        # Basic Attributes
        TAGS_TO_IMPORT = %w{
          type
          genre
          partName
          granuleClass
          abstract
          dates
          length
          action
          contact
          dates
          tocDoc
        }
        
        TAGS_TO_IMPORT.each do |tag_name|
          entry[tag_name.underscore] = entry_node.css(tag_name).first.try(:content)
        end
        
        # Agency 
        agencies = entry_node.css('agency')
        
        entry.primary_agency_raw = agencies[0].try(:content)
        entry.secondary_agency_raw = agencies[1].try(:content)
        
        # if primary_agency_name
        #   primary_agency = Agency.find_or_create_by_name_and_parent_id(normalize_name(primary_agency_name), nil)
        #   
        #   if secondary_agency_name
        #     secondary_agency = Agency.find_or_create_by_name_and_parent_id(normalize_name(secondary_agency_name), primary_agency.id)
        #     entry.agency = secondary_agency
        #   else
        #     entry.agency = primary_agency
        #   end
        # end
        
        # Topics
        topics = []
        entry_node.css('subject topic').each do |topic_node|
          
          # clean up their mess
          topic_name = topic_node.content
          topic_name.sub!(/^and /, '') # remove 'and' at beginning
          topic_names = topic_name.split(/\s*;\s*/).map(&:capitalize) # split on semicolons
          
          topic_names.each do |name|
            next if name.length == 1 # one character topic names help no one
            topics << Topic.find_or_create_by_name(name)
          end
        end
        
        entry.topics = topics
        
        # Urls
        urls = []
        entry_node.css('urlRef').each do |url_ref|
          url = clean_url(url_ref.content)
          urls << Url.find_or_create_by_name(url)
        end
        entry.urls = urls
        
        entry.save!
      end
    end
  end
end