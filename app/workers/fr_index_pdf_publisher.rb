class FrIndexPdfPublisher < FrIndexPdfGenerator
  include CacheUtils

  attr_reader :max_date, :path_manager

  def agency_batch_on_complete(status, params)
    perform(params)
  end

  def perform(params)
    ActiveRecord::Base.clear_active_connections!
    @params   = params.symbolize_keys
    @max_date = Date.parse(@params[:max_date])

    # override max_published so PDF paths are generated correctly
    @params[:last_published] = @max_date
    @path_manager = FileSystemPathManager.new("#{max_date.year}-01-01")

    generate_pdf

    # this is a generic class and we run certain tasks based on the agency presence
    if agency
      update_agency_status
      update_agency_fr_index_json
    else
      update_fr_index_json
      clear_cache
    end
  end

  private

  # we only clear the cache after we've generate all the individual
  # agency pdfs and the combined pdf (which should be enqueued last)
  def clear_cache
    cached_path = path_manager.index_pdf_dir.gsub(path_manager.data_file_path, '')
    purge_cache(cached_path)
    purge_cache("#{cached_path}/*")
  end

  def update_agency_status
    FrIndexAgencyStatus.
      where("year = #{year} AND agency_id = #{agency.id} AND (last_published IS NULL OR last_published < '#{max_date.to_s(:db)}')").
      update_all("last_published = '#{max_date.to_s(:db)}'")
  end

  def update_fr_index_json
    FrIndexCompiler.perform(year)
  end

  def update_agency_fr_index_json
    Sidekiq::Client.enqueue(FrIndexSingleAgencyCompiler, {year: year, agency_id: agency.id})
  end

  def persist_file(file)
    FileUtils.mkdir_p(File.dirname(destination_path), mode: 0755)

    FileUtils.cp(file.path, destination_path)
    FileUtils.chmod(0644, destination_path)
  end

  def destination_path
    if agency
      agency_years.first.published_pdf_path
    else
      fr_index_presenter.published_pdf_path
    end
  end
end
