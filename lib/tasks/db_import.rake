def clean_url(url)
  if url =~ /https?:\/\//
    url
  else
    "http://#{url}"
  end
end

def normalize_name(name)
  name.sub!(/^U.S. /, '') # remove U.S. at beginning
  
  if name !~ /[a-z]/ # ie all uppercase
    name.downcase.capitalize_most_words
  else
    name
  end
end

namespace :db do
  task :import => :environment do
    Entry.transaction do
      Dir.glob("#{RAILS_ROOT}/data/mods/*.xml").each do |file_name|
        doc = Nokogiri::XML(open(file_name))
        
        doc.css('relatedItem').each do |entry_node|
          identifier = entry_node['ID']
          next if identifier.nil?
          
          title = entry_node.css('title').first.try(:content)
          next if title.blank? || title == 'Contents' || title == 'Reader Aids'
          
          
          entry = Entry.find_or_create_by_identifier(identifier)
          
          entry.title = title
          entry.document_number = entry_node.css('accessId').first.try(:content)
          entry.toc_subject = entry_node.css('tocSubject1').first.try(:content)
          
          entry.citation = entry_node.css('identifier[type="preferred citation"]').first.try(:content)
          entry.start_page = entry_node.css('extent[unit="pages"] start').first.try(:content)
          entry.end_page = entry_node.css('extent[unit="pages"] end').first.try(:content)
          # Basic Attributes
          TAGS_TO_IMPORT = %w{
            type
            genre
            partName
            granuleClass
            abstract
            dates
            length
            searchTitle
            action
            contact
            dates
            tocDoc
            effectiveDate
          }

          TAGS_TO_IMPORT.each do |tag_name|
            entry[tag_name.underscore] = entry_node.css(tag_name).first.try(:content)
          end
          
          # Agency 
          agencies = entry_node.css('agency')
          
          primary_agency_name = agencies[0].try(:content)
          secondary_agency_name = agencies[1].try(:content)
          
          agencies = []
          if primary_agency_name
            primary_agency = Agency.find_or_create_by_name_and_parent_id(normalize_name(primary_agency_name), nil)
            agencies << primary_agency
            
            if secondary_agency_name
              secondary_agency = Agency.find_or_create_by_name_and_parent_id(normalize_name(secondary_agency_name), primary_agency.id)
              
              agencies << secondary_agency
            end
          end
          entry.agencies = agencies
          
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
end