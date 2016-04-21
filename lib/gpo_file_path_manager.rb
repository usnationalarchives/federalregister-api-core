class GpoFilePathManager
  attr_reader :cache_bust, :date

  def initialize(date, options={})
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @cache_bust = options.fetch(:cache_bust, true)
  end

  def document_issue_mods_path
    finalize_path "https://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:iso)}/mods.xml"
  end

  private

  def finalize_path(path)
    cache_bust ? "#{path}?#{Time.now.to_i}" : path
  end
end
