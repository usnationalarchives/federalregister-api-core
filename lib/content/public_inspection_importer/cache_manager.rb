class Content::PublicInspectionImporter::CacheManager
  # Load up all the routing, etc needed to clear cache
  include CacheUtils
  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include RouteBuilder

  attr_reader :issue, :pi_documents

  def self.manage_cache(importer)
    new(importer).manage_cache
  end

  def initialize(importer)
    @issue = importer.issue
    @pi_documents = importer.issue.public_inspection_documents.
      includes(:entry => :agencies).
      where("public_inspection_documents.updated_at >= ?",
        importer.start_time
      )
  end

  def manage_cache
    clear_cache if pi_documents.present?
  end

  def clear_cache
    # purge static json cache
    purge_cache "public_inspection_issues/json/#{issue.publication_date.to_s(:ymd)}/special_filing.json"
    purge_cache "public_inspection_issues/json/#{issue.publication_date.to_s(:ymd)}/regular_filing.json"

    # purge api cache
    purge_cache(
      api_v1_public_inspection_documents_path + '*'
    )
    purge_cache '^/api/v1/public-inspection'
  
    # purge issue html cache
    purge_cache "esi/public_inspection_issues/#{issue.publication_date.strftime('%Y')}/#{issue.publication_date.strftime('%m')}"
    purge_cache 'esi/layouts/navigation/public-inspection'
    purge_cache 'esi/issues/summary'
    
    purge_cache public_inspection_documents_by_date_path(issue.publication_date)
    purge_cache public_inspection_documents_path
    
    purge_cache pi_navigation_path


    # purge affected agency cache
    agencies = pi_documents.map(&:agencies).flatten.uniq
    agencies.each do |agency|
      purge_cache agency_path(agency)
    end

    # purge affected individual document caches
    pi_documents.each do |pi_document|
      # clear the short URL cache, so redirects go to the right place
      purge_cache "/d/#{pi_document.document_number}"

      # clear the full URL cache, removing the slug first in
      #   case the document title changed; this should clear
      #   both the old URL and the new (assuming the publication
      #   date didn't change)
      purge_cache entry_path(pi_document).sub(/[^\/]+\z/, '')
    end
  end
end
