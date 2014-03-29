class RegulationsDotGov::Document < RegulationsDotGov::GenericDocument
  def document_id
    raw_attribute_value('documentId')
  end

  def docket_id
    raw_attribute_value('docketId')
  end

  def title
    raw_attribute_value('title')
  end

  def comment_due_date
    val = raw_attributes["commentDueDate"]
    if val.present?
      DateTime.parse(val)
    end
  end

  def comment_url
    if raw_attributes['openForComment']
      "http://www.regulations.gov/#!submitComment;D=#{document_id}"
    end
  end

  def url
    "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
  end

  def comment_count
    # deal with mispelled attribute (and don't break when it's corrected)
    if raw_attributes['numItemsReceived']
      raw_attributes['numItemsReceived']['value'].to_i
    elsif raw_attributes['numItemsRecieved']
      raw_attributes['numItemsRecieved']['value'].to_i
    end
  end

  def federal_register_document_number
    raw_attribute_value('federalRegisterNumber')
  end

  private

  def raw_attribute_value(name)
    raw_attributes[name] ? raw_attributes[name]['value'] : nil
  end
end
