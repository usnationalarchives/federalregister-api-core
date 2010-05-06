module Content::EntryImporter::FullXml
  extend Content::EntryImporter::Utils
  provides :full_xml
  
  def full_xml
    bulkdata_node.to_s if bulkdata_node
  end
  
end