module Content
  class GraphicsExtractor
    class Image
      extend ActiveSupport::Memoizable
      
      def self.all_images_in_file(xml_file_path)
        doc = Nokogiri::XML(open(xml_file_path))
        
        images = []
        doc.css('GID').each do |image_node|
          images << Image.new(image_node)
        end
        
        images
      end
      
      def initialize(image_node)
        @image_node = image_node
      end
      
      def identifier
        @image_node.content()
      end
      memoize :identifier
      
      def page_number
        page_node['P'].to_i
      end
      memoize :page_number
      
      def document_number
        frdoc_node = entry_node.xpath(".//FRDOC").first
        if frdoc_node
          /FR Doc.\s*([^ ;]+)/i.match(frdoc_node.content()).try(:[], 1)
        else
          nil
        end
      end
      memoize :document_number
      
      def num_prior_images_on_page
        count = 0
        page_node.xpath('following::GID').each do |img_node|
          break if img_node == @image_node
          count += 1
        end
        count
      end
      
      # TODO: this should eventually be moved to the initial entry import
      def entry_start_page
        first_node_with_content = entry_node.xpath(".//*[text()]").first
        if first_node_with_content.name == 'PRTPAGE'
          first_node_with_content['P'].to_i
        else
          entry_node.xpath('(preceding::PRTPAGE[count(ancestor::FTNT) = 0])[last()]').first['P'].to_i
        end
      end
      
      private
      
      def page_node
        @image_node.xpath('(preceding::PRTPAGE[count(ancestor::FTNT) = 0])[last()]').first
      end
      memoize :page_node
      
      def entry_node
        @image_node.xpath("ancestor::*[name() = 'RULE' or name() = 'PRORULE' or name() = 'NOTICE' or name() = 'PRESDOCU']")
      end
      memoize :entry_node
    end
  end
end