# this class is to maintain backwards compatibility with our import
# interface. V3 of the Reg.gov document API nests attributes, however
# V3 of the Reg.gov document search API does not nest attributes. We
# deal with that difference here - and only for attributes we care about.
class RegulationsDotGov::SearchDocument < RegulationsDotGov::Document
  def agency_acronym
    raw_attributes['agencyAcronym']
  end

  def allow_late_comment
    raw_attributes['allowLateComment']
  end

  def attachment_count
    raw_attributes['attachmentCount']
  end

  def comment_count
    raw_attributes['numberofCommentsReceived']
  end

  def comment_start_date
    val = raw_attributes["commentStartDate"]
    if val.present?
      DateTime.parse(val)
    end
  end

  def document_id
    raw_attributes['documentId']
  end

  def docket_id
    raw_attributes['docket_id']
  end

  def docketTitle
    raw_attributes['docketTitle']
  end

  def posted_date
    val = raw_attributes['postedDate']
    if val.present?
      DateTime.parse(val)
    end
  end

  def title
    raw_attributes['title']
  end

  def federal_register_document_number
    raw_attributes['frNumber']
  end

  # backwards compatibility
  def metadata
    {}
  end
end
