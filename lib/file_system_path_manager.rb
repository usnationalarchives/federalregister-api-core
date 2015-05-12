class FileSystemPathManager
  attr_reader :date

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
  end

  def document_issue_xml_dir
    "#{Rails.root}/data/document_issues/xml/#{date.to_s(:year_month)}"
  end

  def document_issue_xml_path
    "#{document_issue_xml_dir}/#{date.to_s(:iso)}.xml"
  end

  def document_issue_json_toc_dir
    "#{Rails.root}/data/document_issues/json/#{date.to_s(:year_month)}"
  end

  def document_issue_json_toc_path
    "#{document_issue_json_toc_dir}/#{date.strftime('%d')}.json"
  end

  def public_inspection_issue_json_toc_dir
    "#{Rails.root}/data/public_inspection_issues/json/#{date.to_s(:year_month)}/#{date.strftime('%d')}"
  end

  def public_inspection_issue_regular_filing_json_toc_path
    "#{public_inspection_issue_json_toc_dir}/regular_filing.json"
  end

  def public_inspection_issue_special_filing_json_toc_path
    "#{public_inspection_issue_json_toc_dir}/special_filing.json"
  end

  def index_json_dir
    "data/fr_index/#{date.strftime('%Y')}/"
  end

end
