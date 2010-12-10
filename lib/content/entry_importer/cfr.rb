module Content::EntryImporter::CFR
  extend Content::EntryImporter::Utils
  provides :affected_cfr_titles_and_parts
  
  def affected_cfr_titles_and_parts
    affected_cfr_parts = []
    
    cfr_nodes.each do |cfr_node|
      cfr_node.xpath('./xmlns:part').each do |part_node|
        affected_cfr_parts << [ cfr_node['title'], part_node['number'] ]
      end
    end
    
    affected_cfr_parts
  end
  
  private
  
  def cfr_nodes
    @cfr_node ||= mods_node.xpath('./xmlns:extension/xmlns:cfr') if mods_node
  end
end