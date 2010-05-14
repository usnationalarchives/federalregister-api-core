module Content
  class TopicImporter
    def perform
      delete_existing_topic_data!
      
      doc = Nokogiri::XML(open("#{Rails.root}/data/cfr_index.html"))
      
      topic_nodes = doc.root.css("span[style*='font-size:12.0pt'][style*='font-family: \"Franklin Gothic Medium\"']")
      topic_nodes.each do |topic_node|
        topic_text = clean_up_raw_topic(topic_node.content())
        next unless topic_text
        
        next if topic_text == 'the'
        
        referral_only = topic_node["style"] =~ /color:red/
        next if referral_only
        
        topic = Topic.create(:name => topic_text)
        
        topic_name = TopicName.find_by_name(topic_text)
        if topic_name
          topic_name.topics = [topic]
          topic_name.save
        end
        
        # related_topic_node = topic_node.xpath("(ancestor::p)//span[contains(@style, 'color:blue')]").first
        # if related_topic_node
        #   related_topics = related_topic_node.content().split(/;/).map{|t| clean_up_raw_topic(t)}.compact
        #   related_topics.each {|t| puts "\t#{t}"}
        # end
      end
    end
    
    def delete_existing_topic_data!
      Topic.connection.execute("TRUNCATE topics")
      Topic.connection.execute("TRUNCATE topic_assignments")
      Topic.connection.execute("TRUNCATE topics_topic_names")
    end
    
    def clean_up_raw_topic(raw_topic)
      raw_topic.sub!(/NEVER\s+USE/, '')
      raw_topic.sub!(/SPECIFIC\s+TERMS/, '')
      raw_topic.sub!(/BROADER\s+TERMS/,'')

      raw_topic.sub!(/\([0-9 ,]+\)/, '')
      raw_topic.gsub!(/\s+/, ' ')
      raw_topic.sub!(/^\s+/, '')
      raw_topic.sub!(/\s+$/, '')

      if raw_topic.empty? || raw_topic.size == 1
        nil
      else
        raw_topic
      end
    end
    
  end
end