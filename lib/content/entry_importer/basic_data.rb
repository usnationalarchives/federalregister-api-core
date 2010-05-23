module Content::EntryImporter::BasicData
  extend Content::EntryImporter::Utils
  provides :volume, :title, :toc_subject, :toc_doc, :citation, :regulation_id_number, :start_page, :end_page, :length, :type, :genre, :part_name, :granule_class, :abstract, :dates, :action, :contact
  
  def volume
    mods_file.volume
  end
  
  def title
    simple_node_value('title')
  end
  
  def toc_subject
    simple_node_value('tocSubject1')
  end
  
  def toc_doc
    val = simple_node_value('tocDoc')
    
    if val
      val.sub!(/, $/, '').strip!
    end
    
    val
  end
  
  def citation
    simple_node_value('identifier[type="preferred citation"]')
  end
  
  def regulation_id_number
    regulation_id_number = simple_node_value('identifier[type="regulation ID number"]')
    regulation_id_number.sub!(/RIN /, '') if regulation_id_number.present?
  end
  
  def start_page
    simple_node_value('extent[unit="pages"] start')
  end
  
  def end_page
    simple_node_value('extent[unit="pages"] end')
  end
  
  def length
    simple_node_value('length')
  end
  
  def type
    simple_node_value('type')
  end
  
  def genre
    simple_node_value('genre')
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
  
  private
  
  def simple_node_value(css_selector)
    mods_node.css(css_selector).first.try(:content)
  end
end
