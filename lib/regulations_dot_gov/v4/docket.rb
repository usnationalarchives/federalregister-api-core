class RegulationsDotGov::V4::Docket
  extend Memoist

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def title
    raw_attribute_value('title')
  end

  def regulation_id_number
    rin = raw_attribute_value('rin')

    if rin.blank? || rin == 'Not Assigned'
      nil
    else
      rin
    end
  end

  def docket_id
    raw_attributes['id']
  end

  def supporting_documents
    docket_documents_raw_response.fetch('data').map do |raw_attributes|
      RegulationsDotGov::V4::BasicDocument.new(raw_attributes)
    end
  end
  memoize :supporting_documents

  def supporting_documents_count
    docket_documents_raw_response.fetch('meta').fetch('totalElements')
  end

  def comments_count
    # We decided we won't persist this any longer becasue V4 requires additional API calls for it.
  end

  def metadata
    # Called in DocketImporter interface, but this attribute was used for backwards compatibility and is no-longer needed.  Keeping it here for now so the DocketImporter code can run without errors, but we probably want to stop setting the metadata attribute in the DocketImporter long-term.
    nil
  end

  private

  attr_reader :raw_attributes

  def docket_documents_raw_response
    "foo".to_s
    RegulationsDotGov::V4::Client.new.find_documents_by_docket(docket_id)
  end
  memoize :docket_documents_raw_response

  def raw_attribute_value(name)
    raw_attributes['attributes'][name]
  end


end
