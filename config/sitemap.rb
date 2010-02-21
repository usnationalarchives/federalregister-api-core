# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://govpulse.us"
SitemapGenerator::Sitemap.subdirectory = "sitemaps"

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add path, options
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly', 
  #           :lastmod => Time.now, :host => default_host

  
  # SPECIAL PAGES
  sitemap.add about_path, :priority => 1
  sitemap.add vote_path,  :priority => 0.75
  
  # ENTRIES
  Entry.find_each do |entry|
    sitemap.add entry_path(entry)
  end
  
  Entry.connection.select_values("SELECT DISTINCT(publication_date) FROM entries").each do |date|
    sitemap.add entries_by_date_path(Date.parse(date))
  end
  
  # EVENTS
  ReferencedDate.connection.select_values("SELECT DISTINCT(date) FROM referenced_dates").each do |date|
    sitemap.add events_path(Date.parse(date))
  end
  
  # TOPICS
  ('a' .. 'z').each do |letter|
    sitemap.add topic_groups_by_letter_path(letter), :priority => 0.25
  end
  TopicGroup.find_each do |topic_group|
    sitemap.add topic_group_path(topic_group)
  end
  
  # AGENCIES
  sitemap.add agencies_path
  Agency.find_each do |agency|
    sitemap.add agency_path(agency)
  end
  
  # PLACES
  Place.find_each do |place|
    sitemap.add place_path(place), :priority => 0.25
  end
end
