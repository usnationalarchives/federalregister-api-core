module Content::EntryImporter::LedePhotoCandidates
  extend ActiveSupport::Memoizable
  # extend Content::EntryImporter::Utils
  # provides :lede_photo_suggestions
  
  def lede_photo_candidates
    if false && entry.lede_photo_candidates
      entry.lede_photo_candidates
    elsif entry.abstract.present?
      tags = SocialTagExtractor.new.extract(entry.abstract)
    
      suggestions = []
      tags.each do |tag|
        suggestions << [tag, flickr_info_for_tag(tag)]
      end
    
      YAML::dump(suggestions)
    end
  end
  
  def flickr_info_for_tag(tag_name)
    Flickr.new.search(tag_name)
  end
  memoize :flickr_info_for_tag
end