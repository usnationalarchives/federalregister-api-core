module Content::EntryImporter::SornDetails
  extend Content::EntryImporter::Utils
  extend Memoist
  provides :sorn_system_name, :sorn_system_number, :notice_type_id

  def sorn_system_name
    if sorn?
      sorn_xml_parser.get_system_name
    end
  end

  def sorn_system_number
    if sorn?
      sorn_xml_parser.get_system_number
    end
  end

  def notice_type_id
    if sorn?
      NoticeType::SORN.id
    elsif sunshine_act_meeting?
      NoticeType::SUNSHINE_ACT_MEETING.id
    end
  end

  private

  SUNSHINE_ACT_SUBJECT_REGEX = /^sunshine\s+act\s+meetings?/i
  def sunshine_act_meeting?
    subject_node &&
    subject_node.text &&
    SUNSHINE_ACT_SUBJECT_REGEX.match?(subject_node.text)
  end

  def subject_node
    @bulkdata_node.css('PREAMB SUBJECT')
  end
  memoize :subject_node

  def sorn_xml_parser
    SornXmlParser.new(bulkdata_node.to_xml)
  end
  memoize :sorn_xml_parser

  def sorn?
    priact_node && priact_node.text
  end
  memoize :sorn?

  def priact_node
    @bulkdata_node && @bulkdata_node.css('PRIACT P').first
  end
  memoize :priact_node

end
