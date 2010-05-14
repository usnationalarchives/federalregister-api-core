module Content::EntryImporter::TopicNames
  extend Content::EntryImporter::Utils
  provides :topic_names
  
  def topic_names
    topic_names = []
    mods_node.css('subject topic').each do |topic_node|
      
      # clean up their mess
      name = topic_node.content
      name.sub!(/^and /, '') # remove 'and' at beginning
      names = name.split(/\s*;\s*/).map(&:capitalize) # split on semicolons
      
      names.each do |name|
        next if name.length == 1 # one character topic names help no one
        topic_names << TopicName.find_or_create_by_name(name)
      end
    end
    
    topic_names
  end
end