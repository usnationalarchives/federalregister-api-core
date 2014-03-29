class RegulationsDotGov::Docket < RegulationsDotGov::GenericDocument
  def title
    raw_attributes['title']
  end

  def regulation_id_number
    rin = raw_attributes['rin']

    if rin.blank? || rin == 'Not Assigned'
      nil
    else
      rin
    end
  end

  def docket_id
    raw_attributes['docketId']
  end

  def supporting_documents
    @client.find_documents(:dktid => docket_id, :dct => 'SR', :so => 'DESC', :sb => 'docId')
  end

  def supporting_documents_count
    @client.count_documents(:dktid => docket_id, :dct => 'SR')
  end

  def comments_count
    @client.count_documents(:dktid => docket_id, :dct => 'PS')
  end

  # backwards compatibility
  def metadata
    {}
  end
end
