module Content
  class GraphicsExtractor
    class Entry
      extend ActiveSupport::Memoizable
      
      attr_reader :entry
      def initialize(document_number, options)
        @entry = ::Entry.find_by_document_number(document_number)
        @base_dir = options[:base_dir]
      end
      
      def pdf_file_path
        file_loc = "#{@base_dir}/#{entry.document_number}.pdf"
        FederalRegisterFileRetriever.download(entry.source_url(:pdf), file_loc) unless File.exists?(file_loc)
        file_loc
      end
      
      def pdf_images_by_page
        pdf = Stevedore::Pdf.new(pdf_file_path)
        
        pdf_images_by_page = Hash.new{ Array.new }
        pdf.images(@base_dir).each do |pdf_image|
          pdf_images_by_page[pdf_image.page_number] += [pdf_image]
        end
        
        pdf_images_by_page
      end
      memoize :pdf_images_by_page
      
      def associate_image(image)
        puts "Processing #{image.identifier} (##{image.num_prior_images_on_page + 1} on page #{image.page_number}) for #{entry.document_number}"
        graphic = Graphic.find_by_identifier(image.identifier) || Graphic.new(:identifier => image.identifier)
        
        pdf_page_number = (image.page_number - entry.start_page)+1
        unless graphic.graphic.file?
          pdf_image = pdf_images_by_page[pdf_page_number][ image.num_prior_images_on_page ]
          if pdf_image
            graphic.graphic = File.open(pdf_image.file_path)
          else
            puts "\tpdf image ##{image.num_prior_images_on_page} on page (#{pdf_page_number}) not present (images on #{pdf_images_by_page.keys.sort.join(', ')})"
            Content::PageImageExtractor.new(entry, pdf_file_path, image.page_number).extract!
          end
        end
        
        graphic.entries << entry unless graphic.entry_ids.include?(entry.id)
        graphic.save!
      end
    end
  end
end
