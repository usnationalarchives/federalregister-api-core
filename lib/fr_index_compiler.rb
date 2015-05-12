class FrIndexCompiler
  attr_reader :index, :agencies, :path_manager

  def initialize(year)
    @year = year.to_i
    @agencies = FrIndexPresenter.new(@year).agencies_with_pseudonyms
    @path_manager = FileSystemPathManager.new(Date.new(@year,01,01).to_s(:iso))
    @index = {agencies:[]}
  end

  def self.perform(date)
    date = date.is_a?(Date) ? date : Date.parse(date)
    year = date.strftime('%Y')
    fr_index_compiler = new(year)
    fr_index_compiler.process_agencies
    fr_index_compiler.save(fr_index_compiler.index)
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

  def process_see_also(child_agencies)
    child_agencies.map do |child_agency|
      {
        name: child_agency.agency.name,
        slug: child_agency.agency.slug
      }
    end
  end

  def save(index)
    FileUtils.mkdir_p(path_manager.index_json_dir)

    File.open "#{path_manager.index_json_dir}index.json", 'w' do |f|
      f.write(index.to_json)
    end
  end

end
