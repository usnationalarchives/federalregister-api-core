module Content::EntryImporter::TopicNames
  extend Content::EntryImporter::Utils
  provides :topic_names
  
  def topic_names
    topics = []
    mods_node.css('subject topic').each do |topic_node|
      
      # clean up their mess
      topic_name = topic_node.content
      topic_name.sub!(/^and /, '') # remove 'and' at beginning
      topic_names = topic_name.split(/\s*;\s*/).map(&:capitalize) # split on semicolons
      
      topic_names.each do |name|
        next if name.length == 1 # one character topic names help no one
        topic_names << TopicName.find_or_create_by_name(name)
      end
    end
    
    topic_names
  end
end