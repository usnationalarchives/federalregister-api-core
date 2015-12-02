module Content::EntryImporter::BasicData
  extend Content::EntryImporter::Utils
  provides :volume, :issue_number, :title, :toc_subject, :toc_doc, :citation, :regulation_id_numbers, :significant, :start_page, :end_page, :part_name, :granule_class, :abstract, :dates, :action, :contact, :docket_numbers, :correction_of_id
  
  def volume
    mods_file.volume
  end

  def issue_number
    mods_file.issue_number
  end
  
  def title
    simple_node_value('title')
  end
  
  def toc_subject
    simple_node_value('tocSubject1')
  end
  
  def toc_doc
    val = simple_node_value('tocDoc')
    
    if val.present?
      val = val.sub(/, $/, '').strip
    end
    
    val
  end
  
  def citation
    simple_node_value('identifier[type="preferred citation"]')
  end
  
  def regulation_id_numbers
    regulation_id_numbers = simple_node_values('identifier[type="regulation ID number"]')
    regulation_id_numbers.map{|rin| rin.sub(/RIN /, '').upcase}
  end
  
  def significant
    entry.current_regulatory_plans.any?(&:significant?)
  end
  
  def start_page
    simple_node_value('extent[unit="pages"] start')
  end
  
  def end_page
    simple_node_value('extent[unit="pages"] end')
  end
  
  def part_name
    simple_node_value('partName')
  end
  
  def granule_class
    simple_node_value('granuleClass')
  end
  
  def abstract
    simple_node_value('abstract')
  end
  
  def dates
    simple_node_value('dates')
  end
  
  def action
    simple_node_value('action')
  end
  
  def contact
    simple_node_value('contact')
  end
  
  def docket_numbers
    simple_node_values('departmentDoc').map{|number| DocketNumber.new(:number => number)}
  end

  def correction_of_id
    document_number.scan(/^[CR]\d-(.*)/).each do |corrected_document_number|
      return Entry.find_by_document_number(corrected_document_number.first).try(:id)
    end

    return nil
  end
  
  private
  
  def simple_node_value(css_selector)
    mods_node.css(css_selector).first.try(:content)
  end
  
  def simple_node_values(css_selector)
    mods_node.css(css_selector).map(&:content)
  end
end
