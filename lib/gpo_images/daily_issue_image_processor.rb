module GpoImages
  class DailyIssueImageProcessor
    attr_reader :date, :documents
    include ImageIdentifierNormalizer

    XML_IMAGE_TAGS = ['GID', 'MID']

    def initialize(date)
      @date = date
      @documents = Entry.find_all_by_publication_date(@date)
    end

    def self.perform(date)
      new(date).perform
    end

    def perform
      scan_documents_for_images
    end

    class ImageUsage
      attr_reader :image_identifier, :document_number, :xml_identifier

      delegate :graphic_file_name?, :move_to_public_bucket, :to => :gpo_graphic

      def initialize(image_identifier, document_number, xml_identifier)
        @image_identifier = image_identifier
        @document_number = document_number
        @xml_identifier = xml_identifier
      end

      def gpo_graphic
        @gpo_graphic ||= GpoGraphic.find_by_identifier(image_identifier)
      end

      def gpo_graphic_exists?
        gpo_graphic.present?
      end

      def gpo_graphic_usage_exists?
        gpo_graphic_usage.present?
      end

      def gpo_graphic_usage
        @graphic_usage ||= GpoGraphicUsage.find_by_identifier_and_document_number(
          image_identifier,
          document_number
        )
      end

      def create_graphic_usage
        GpoGraphicUsage.create(
          :identifier => image_identifier,
          :document_number => document_number,
          :xml_identifier => xml_identifier
        )
      end

    end

    private

    def scan_documents_for_images
      XML_IMAGE_TAGS.each do |xml_tag|
        image_usages(xml_tag).each do |image_usage|

          # move existing graphic to public bucket if it has an image associated
          # or create one if it doesn't exist (ie we're missing an image)
          if image_usage.gpo_graphic_exists?
            if image_usage.graphic_file_name?
              move_to_public_bucket = true
            end
          else
            GpoGraphic.create(:identifier => image_usage.image_identifier)
          end

          # update the xml_identifier for existing graphic usages
          # or create one if it doesn't exist
          if image_usage.gpo_graphic_usage_exists?
            puts "adding xml_identifier #{image_usage.xml_identifier}"
            image_usage.gpo_graphic_usage.xml_identifier = image_usage.xml_identifier
            image_usage.gpo_graphic_usage.save
            image_usage.gpo_graphic_usage.reload
          else
            image_usage.create_graphic_usage
          end

          image_usage.move_to_public_bucket if move_to_public_bucket
        end
      end
    end

    def image_usages(xml_tag)
      documents.each_with_object([]) do |document, image_usages|
        puts "missing xml for #{document.document_number}" unless document.full_xml.present?

        xml_doc = Nokogiri::XML(document.full_xml)
        xml_doc.css(xml_tag).each do |node|
          image_usages << ImageUsage.new(
            normalize_image_identifier(node.text),
            document.document_number,
            node.text
          )
        end
      end
    end

  end
end
