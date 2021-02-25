module RegulationsDotGov::V4::CommonDocumentAttributes
  extend Memoist

  def agency_acronym
    raw_attribute_value('agencyId')
  end

  def comment_due_date
    val = raw_attribute_value("commentEndDate")
    if val.present?
      DateTime.parse(val)
    end
  end

  def comment_count
    RegulationsDotGov::V4::Client.new.find_comments_by_comment_on_id(comment_on_id).count
  end
  memoize :comment_count

  def comment_url
    if raw_attribute_value('openForComment') && !non_participating_agency?
      "http://www.regulations.gov/#!submitComment;D=#{document_id}"
    end
  end

  def document_id
    raw_attributes['id']
  end

  def docket_id
    raw_attribute_value('docketId')
  end

  def non_participating_agency?
    DocketImporter.non_participating_agency_ids.include?(agency_acronym)
  end

  def title
    raw_attribute_value('title')
  end

  def url
    "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
  end


  private

  attr_reader :raw_attributes

  def raw_attribute_value(name)
    raw_attributes['attributes'][name]
  end

  def comment_on_id
    raw_attribute_value('objectId')
  end

end
