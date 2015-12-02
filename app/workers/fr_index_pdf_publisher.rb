class FrIndexPdfPublisher < FrIndexPdfGenerator
  include CacheUtils

  @queue = :fr_index_pdf_publisher

  attr_reader :max_date
  def initialize(params)
    @params = params.symbolize_keys
    @max_date = Date.parse(@params[:max_date])

    # override max_published so PDF paths are generated correctly
    @params[:last_published] = @max_date
  end

  def perform
    super
    update_agency_status
    clear_cache
  end

  private

  def clear_cache
    # only clear the cache after we've generate all the individual
    # agency pdfs and the combined pdf (which should be enqueued last)
    if !agency
      purge_cache("/index/#{year}")
      purge_cache("/index/#{year}/*")
    end
  end

  def update_agency_status
    if agency
      FrIndexAgencyStatus.update_all(
        "last_published = '#{max_date.to_s(:db)}'", 
        "year = #{year} AND agency_id = #{agency.id} AND (last_published IS NULL OR last_published < '#{max_date.to_s(:db)}')")
    end
  end

  def persist_file(file)
    FileUtils.mkdir_p(File.dirname(destination_path))

    FileUtils.cp(file.path, destination_path)
    FileUtils.chmod(644, destination_path)
  end

  def destination_path
    if agency
      'public' + agency_years.first.published_pdf_path
    else
      'public' + fr_index_presenter.published_pdf_path
    end
  end
end
