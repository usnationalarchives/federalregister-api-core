class FrIndexCompiler
  attr_reader :agencies, :index, :path_manager, :year

  def initialize(year)
    @year = year.to_i
    @agencies = FrIndexPresenter.new(@year).agencies_with_pseudonyms
    @path_manager = FileSystemPathManager.new("#{@year}-01-01")
    @index = {agencies:[]}
  end

  def self.perform(year)
    new(year).perform
  end

  def perform
    process_agencies
    add_pdf_metadata
    save(index)
    clear_cache
  end

  def process_agencies
    agencies.each do |agency|
      if agency.class == FrIndexPresenter::AgencyPseudonym
        index[:agencies] << {
          name: agency.agency.pseudonym,
          slug: nil,
          see_also: [{name: agency.agency.name, slug: agency.agency.slug}]
        }
      else
        index[:agencies] << {
          name: agency.agency.name,
          slug: agency.agency.slug
        }.
        tap do |hsh| hsh["see_also"] =
          process_see_also(agency.children) if process_see_also(agency.children).present?
        end
      end
    end
    agencies
  end

  def add_pdf_metadata
    last_published_date = FrIndexAgencyStatus.
      scoped(
        order: "last_published DESC",
        conditions: ["last_published IS NOT NULL and YEAR = ?", year],
      ).
      first.
      try(:last_published)

    if last_published_date
      index[:pdf] = {
        url: "#{SETTINGS['app']['canonical_url']}#{path_manager.index_pdf_path(last_published_date).gsub(path_manager.send(:data_file_path),'')}",
        approval_date: last_published_date.to_s(:iso),
      }
    else
      index[:pdf] = {
        url: nil,
        approval_date: nil,
      }
    end
  end

  def process_see_also(child_agencies)
    child_agencies.map do |child_agency|
      {
        name: child_agency.agency.name,
        slug: child_agency.agency.slug
      }
    end
  end

  def save(index)
    FileUtils.mkdir_p(path_manager.index_json_dir, mode: 0755)

    File.open(path_manager.index_json_path, 'w') do |f|
      f.write(index.to_json)
    end
  end

  def clear_cache
    cached_path = path_manager.index_json_path.gsub(path_manager.data_file_path, '')
    CacheUtils.purge_cache(cached_path)
  end
end
