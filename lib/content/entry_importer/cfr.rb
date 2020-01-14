module Content::EntryImporter::Cfr
  extend Content::EntryImporter::Utils
  provides :entry_cfr_references

  def entry_cfr_references
    entry_cfr_references = []

    cfr_nodes.each do |cfr_node|
      cfr_node.xpath('./xmlns:part | ./xmlns:chapter').each do |chapter_or_part_node|
        entry_cfr_references << EntryCfrReference.new(:title => cfr_node['title'], chapter_or_part_node.name => chapter_or_part_node['number'])
      end
    end

    entry_cfr_references
  end

  private

  def cfr_nodes
    @cfr_node ||= mods_node.xpath('./xmlns:extension/xmlns:cfr') if mods_node
  end
end
