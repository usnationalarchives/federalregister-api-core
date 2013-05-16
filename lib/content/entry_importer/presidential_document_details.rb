module Content::EntryImporter::PresidentialDocumentDetails
  extend Content::EntryImporter::Utils

  provides :presidential_document_type_id,
    :signing_date,
    :executive_order_number,
    :executive_order_notes

  def presidential_document_type_id
    child_node = @bulkdata_node && @bulkdata_node.xpath('./*').first
    if child_node
      return PresidentialDocumentType.find_by_node_name(child_node.name).try(:id)
    end
  end

  def signing_date
    date_node = @bulkdata_node && @bulkdata_node.css('DATE').first
    if date_node && date_node.text =~ /(\w+ \d+, \d{4})/
      # eg 'January 18, 2007'
      str = $1
      begin
        Date.strptime(str, '%B %d, %Y')
      rescue
        nil
      end
    end
  end

  def executive_order_number
    execordr_node = @bulkdata_node && @bulkdata_node.css('EXECORDR').first
    if execordr_node
      execordr_node.text.scan(/Executive Order (\d+)/) do |captures|
        return captures.first.to_i
      end
    end
  end

  def executive_order_notes
    notes_nodes = mods_node.css('noprinteonotes')
    if notes_nodes.present?
      notes_nodes.map(&:content).join("\n")
    else
      @entry.try(:executive_order_notes)
    end
  end
end
