class GpoImages::DailyIssueImageProcessor
  attr_reader :date, :documents, :fog_aws_connection

  XML_IMAGE_TAGS = ['GID', 'MID']

  def initialize
    custom_date = Date.parse ENV['DATE'] if ENV['DATE']
    @date ||= custom_date || Issue.current.publication_date
    @documents ||= Entry.find_all_by_publication_date(@date)
  end

  def self.perform
    new.perform
  end

  def perform
    scan_documents_for_images
  end

  class ImageUsage
    attr_reader :image_identifier, :document_number, :fog_aws_connection,
    :private_bucket, :public_bucket
    delegate :graphic_file_name?, :copy_to_public_bucket, :to => :gpo_graphic

    def initialize(image_identifier, document_number)
      @image_identifier = image_identifier
      @document_number = document_number
    end

    def gpo_graphic
      @gpo_graphic ||= GpoGraphic.find_by_identifier(image_identifier)
    end

    def gpo_graphic_exists?
      gpo_graphic.present?
    end

    def create_gpo_graphic_usage_unless_existent
      if GpoGraphicUsage.find_by_identifier_and_document_number(
        image_identifier,
        document_number
        ).nil?

        create_graphic_usage
      end
    end

    def paperclip_image?
      graphic_file_name?
    end

    def create_graphic_usage
      GpoGraphicUsage.create(
        :identifier => image_identifier,
        :document_number => document_number
      )
    end

  end

  private

  def scan_documents_for_images
    XML_IMAGE_TAGS.each do |xml_tag|
      image_usages(xml_tag).each do |image_usage|
        if image_usage.gpo_graphic_exists?
          if image_usage.paperclip_image?
            image_usage.copy_to_public_bucket
          end
        else
          GpoGraphic.create(:identifier => image_usage.image_identifier)
        end

        image_usage.create_gpo_graphic_usage_unless_existent
      end
    end
  end

  def image_usages(xml_tag)
    documents.each_with_object([]) do |document, image_usages|
      xml_doc = Nokogiri::XML(document.full_xml)
      xml_doc.css(xml_tag).each do |node|
        image_usages << ImageUsage.new(node.text, document.document_number)
      end
    end
  end

end
