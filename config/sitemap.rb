# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.federalregister.gov"

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
  
  # SEARCHES
  sitemap.add entries_search_path, :priority => 1
  sitemap.add public_inspection_search_path, :priority => 0.75 
  sitemap.add events_search_path, :priority => 0.5
  sitemap.add regulatory_plans_search_path, :priority => 0.5

  # SECTIONS
  Section.find_each do |section|
    sitemap.add section_path(section), :priority => 0.75, :changefreq => 'daily'
    sitemap.add about_section_path(section), :priority => 0.25, :changefreq => 'daily'
  end

  # CANNED SEARCHES
  CannedSearch.active.each do |canned_search|
    sitemap.add canned_search_path(canned_search), :priority => 0.75, :changefreq => 'daily'
  end
  
  # ENTRIES
  Entry.scoped(:joins => :issue, :conditions => "issues.publication_date > '2011-10-01' && issues.completed_at IS NOT NULL").find_each do |entry|
    sitemap.add entry_path(entry), :changefreq => 'monthly', :lastmod => entry.updated_at
  end
  
  Issue.completed.find_each do |issue|
    sitemap.add entries_by_date_path(issue.publication_date), :priority => 0.75
  end
  
  sitemap.add entries_current_issue_path, :priority => 1.0, :changefreq => 'daily'
 
  PublicInspectionIssue.published.find_each do |issue|
    sitemap.add public_inspection_documents_by_date_path(issue.publication_date), :priority => 0.75
  end

  sitemap.add public_inspection_documents_path, :priority => 1.0, :changefreq => 'hourly'

  PublicInspectionDocument.unpublished.find_each do |document|
    sitemap.add entry_path(document)
  end

  # TOPICS
  sitemap.add topics_path
  Topic.find_each do |topic|
    sitemap.add topic_path(topic), :changefreq => 'daily'
  end
  
  # AGENCIES
  sitemap.add agencies_path
  Agency.find_each do |agency|
    sitemap.add agency_path(agency), :priority => 0.75, :changefreq => 'daily'
  end
 
  # REGULATIONS
  RegulatoryPlan.find_each do |regulatory_plan|
    sitemap.add regulatory_plan_path(regulatory_plan), :changefreq => 'daily'
  end
end
