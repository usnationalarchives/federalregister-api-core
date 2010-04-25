module Content
  class EntryImporter
    module PageNumber
      extend ActiveSupport::Memoizable
      extend Content::EntryImporter::Utils
      provides :start_page, :end_page
        
      def start_page
        if bulkdata_node
          first_node_with_content = bulkdata_node.xpath("descendant::text()[normalize-space(.)]")
          first_node_with_content.xpath('(preceding::PRTPAGE[count(ancestor::FTNT) = 0])[last()]').first['P'].to_i
        else
          mods_node.css('extent[unit="pages"] start').first.try(:content).try(:to_i)
        end
      end
      memoize :start_page
        
      def end_page
        if bulkdata_node
          last_page_node = bulkdata_node.xpath(".//PRTPAGE[last()]").first
      
          if last_page_node
            last_page_node['P'].to_i
          else
            start_page
          end
        else
          mods_node.css('extent[unit="pages"] end').first.try(:content).try(:to_i)
        end
      end
      memoize :end_page
    end
  end
end