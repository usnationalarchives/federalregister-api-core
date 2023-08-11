class Content::PublicInspectionImporter::CacheManager
  # Load up all the routing, etc needed to clear cache
  include CacheUtils
  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include RouteBuilder

  attr_reader :issue, :pi_documents

  def self.manage_cache(issue_id, start_time)
    new(issue_id, start_time).manage_cache
  end

  def initialize(issue_id, start_time)
    @issue = PublicInspectionIssue.find(issue_id)
    @pi_documents = issue.public_inspection_documents.
      includes(:entry => :agencies).
      where("public_inspection_documents.updated_at >= ?",
        start_time
      )
  end

  def manage_cache
    clear_cache if pi_documents.present?
    purge_cloundfront
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

  def purge_cloundfront
    # purge cloudfront cache where PIL pdf changes were detected.
    redis_set_name = "pil_document_numbers_for_cloudfront_expiry_#{issue.publication_date.to_s(:iso)}"
    pil_doc_numbers = $redis.smembers(redis_set_name)
    if pil_doc_numbers.present?
      Sidekiq::Client.enqueue(CloudfrontPublicInspectionDocumentCacheInvalidator, pil_doc_numbers)
    end
    $redis.del(redis_set_name)
  end
end
