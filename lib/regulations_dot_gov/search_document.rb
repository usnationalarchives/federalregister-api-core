# this class is to maintain backwards compatibility with our import
# interface. V3 of the Reg.gov document API nests attributes, however
# V3 of the Reg.gov document search API does not nest attributes. We
# deal with that difference here - and only for attributes we care about.
class RegulationsDotGov::SearchDocument < RegulationsDotGov::Document
  def document_id
    raw_attributes['documentId']
  end

  def title
    raw_attributes['title']
  end

  # backwards compatibility
  def metadata
    {}
  end
end
