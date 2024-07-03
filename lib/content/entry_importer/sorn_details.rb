module Content::EntryImporter::SornDetails
  extend Content::EntryImporter::Utils
  extend Memoist
  provides :sorn_system_name, :sorn_system_number

  def sorn_system_name
    if priact_node && priact_node.text
      priact_node.text.split(',').first.strip
    end
  end

  def sorn_system_number
    if priact_node && priact_node.text
      priact_node.text.split(',').last.strip
    end
  end


  private

  def priact_node
    @bulkdata_node && @bulkdata_node.css('PRIACT P').first
  end
  memoize :priact_node

end
