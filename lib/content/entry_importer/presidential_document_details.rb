module Content::EntryImporter::PresidentialDocumentDetails
  extend Content::EntryImporter::Utils

  provides :presidential_document_type_id,
    :signing_date,
    :executive_order_notes,
    :presidential_document_number,
    :president_id

  def presidential_document_type_id
    document_type_id = nil
    if mods_node
      presdoc_node = mods_node.css('presidentialDoc')
      if presdoc_node.present?
        document_type_id = PresidentialDocumentType.find_by_node_name(
          presdoc_node.attr('type').try(:value)
        ).try(:id)
      end
    end

    return document_type_id if document_type_id

    # fall back to bulkdata node if available
    if bulkdata_node
      child_node = bulkdata_node.xpath('./*').first
      if child_node
        return PresidentialDocumentType.find_by_node_name(child_node.name).try(:id)
      end
    end
  end

  def signing_date
    date = nil
    if mods_node
      presdoc_node = mods_node.css('presidentialDoc')

      if presdoc_node.present?
        date = presdoc_node.attr('date').try(:value)
      end
    end

    return date if date

    # presidential orders only use full text for signing date
    if bulkdata_node
      date_node = bulkdata_node.css('ORDER').first
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
  end

  def executive_order_notes
    notes_nodes = mods_node.css('noprinteonotes')
    if notes_nodes.present?
      notes_nodes.map(&:content).join("\n")
    else
      @entry.try(:executive_order_notes)
    end
  end

  def presidential_document_number
    if mods_node
      presdoc_node = mods_node.css('presidentialDoc')

      if presdoc_node.present?
        return presdoc_node.attr('number').try(:value)
      end
    end
  end

  def president_id
    if mods_node
      president_node = mods_node.css('president')

      if president_node.present?
        president_id = president_node.attr('id').try(:value)
        President.find_by_mods_file_id(president_id)&.id
      end
    end
  end

end
