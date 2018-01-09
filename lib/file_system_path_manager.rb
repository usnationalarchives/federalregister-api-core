class FileSystemPathManager
  attr_reader :date

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
  end

  # DOCUMENT ISSUES
  def document_issue_xml_dir
    "#{data_file_path}/document_issues/xml/#{date.to_s(:year_month)}"
  end

  def document_issue_xml_path
    "#{document_issue_xml_dir}/#{date.to_s(:iso)}.xml"
  end

  def document_issue_json_toc_dir
    "#{data_file_path}/document_issues/json/#{date.to_s(:year_month)}"
  end

  def document_issue_json_toc_path
    "#{document_issue_json_toc_dir}/#{date.strftime('%d')}.json"
  end

  # PUBLIC INSPECTION DOCUMENT ISSUES
  def public_inspection_issue_json_toc_dir
    "#{data_file_path}/public_inspection_issues/json/#{date.to_s(:year_month)}/#{date.strftime('%d')}"
  end

  def public_inspection_issue_regular_filing_json_toc_path
    "#{public_inspection_issue_json_toc_dir}/regular_filing.json"
  end

  def public_inspection_issue_special_filing_json_toc_path
    "#{public_inspection_issue_json_toc_dir}/special_filing.json"
  end

  # FR INDEX
  def index_json_dir
    "#{data_file_path}/fr_index/#{date.strftime('%Y')}/"
  end

  # DOCUMENTS
  def document_mods_dir
    "#{data_file_path}/documents/mods/#{date.to_s(:year_month)}"
  end

  def document_mods_path
    "#{document_mods_dir}/#{date.to_s(:db_year)}.xml"
  end

  def document_archive_mods_dir
    "#{document_mods_dir}/archive"
  end

  def document_archive_mods_path(time)
    "#{document_archive_mods_dir}/#{date.to_s(:db_year)}-#{time}.xml"
  end

  def document_temporary_mods_dir
    "#{document_mods_dir}/tmp"
  end

  def document_temporary_mods_path
    "#{document_temporary_mods_dir}/#{date.to_s(:db_year)}.xml"
  end

  private

  def data_file_path
    "#{Rails.root}/data/efs"
  end

  def self.data_file_path
    "#{Rails.root}/data/efs"
  end
end
