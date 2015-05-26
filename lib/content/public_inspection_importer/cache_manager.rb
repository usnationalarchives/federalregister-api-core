class Content::PublicInspectionImporter::CacheManager
  # Load up all the routing, etc needed to clear cache
  include CacheUtils
  include ActionController::UrlWriter
  include ApplicationHelper
  include RouteBuilder

  attr_reader :pi_documents

  def self.manage_cache(importer)
    @pi_documents = importer.issue.public_inspection_documents.find(
      :all,
      :include => {:entry => :agencies},
      :conditions => [
        "public_inspection_documents.updated_at >= ?",
        importer.issue.start_time
      ]
    )

    clear_cache if documents.present?
  end

  def self.clear_cache
    # purge issue cache
    purge_cache public_inspection_documents_by_date_path(issue.publication_date)
    purge_cache public_inspection_documents_path
    purge_cache(
      api_v1_public_inspection_documents_path + '*'
    )
    purge_cache pi_navigation_path

    # purge affected agency cache
    agencies = pi_documents.map(&:agencies).flatten.uniq
    agencies.each do |agency|
      purge_cache agency_path(agency)
    end

    # purge affected individual document caches
    pi_documents.each do |pi_document|
      purge_cache entry_path(pi_document.document)
    end
  end
end
