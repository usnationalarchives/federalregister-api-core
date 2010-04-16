module EntryImporter::CFR
  extend EntryImporter::Utils
  provides :cfr_title, :cfr_part
  
  def cfr_node
    mods_node.xpath('./xmlns:extension/xmlns:cfr').first
  end
  
  def cfr_title
    cfr_node['title'] if cfr_node
  end
  
  def part_node
    cfr_node.xpath('./xmlns:part').first if cfr_node
  end
  
  def cfr_part
    part_node['number'] if part_node
  end
  
end