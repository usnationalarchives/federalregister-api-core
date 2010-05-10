class SocialTagExtractor
  def license_id
    ENV["open_calais_api_key"]
  end
  
  def extract(text)
    if text.present?
      response = Calais.enlighten(
        :content => text[0, 100_000], # send first 100k characters
        :license_id => license_id,
        :metadata_enables => ["SocialTags"],
        :metadata_discards => ['er/Company', 'er/Geo', 'er/Product']
      )
      
      social_tag_nodes = Nokogiri::XML(response).root.xpath('rdf:Description/rdf:type[@rdf:resource="http://s.opencalais.com/1/type/tag/SocialTag"]')
      
      social_tags = []
      social_tag_nodes.each do |node|
        social_tags << node.xpath('following-sibling::c:name').first.content
      end
      
      social_tags
    else
      []
    end
  end
end