class GpoImages::DailyIssueImporter
  attr_reader :date, :documents, :fog_aws_connection

  XML_IMAGE_TAGS = ['GID', 'MID']

  def initialize(date=Date.current)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @documents ||= Entry.find_all_by_publication_date(@date)
  end

  def self.perform(date=Date.current)
    new(date).perform
  end

  def perform
    process_documents
  end

  class DocumentGraphic
    attr_reader :image_identifier, :document_number, :fog_aws_connection,
    :private_bucket, :public_bucket

    def initialize(image_identifier, document_number)
      @image_identifier = image_identifier
      @document_number = document_number
      @fog_aws_connection ||= GpoImages::FogAwsConnection.new
      @private_bucket = "#{SETTINGS["private_processed_images_s3_bucket_prefix"]}.fr2.criticaljuncture.org" #TODO: Change to be dynamic in prod
      @public_bucket = "#{SETTINGS["public_processed_images_s3_bucket_prefix"]}.fr2.criticaljuncture.org" #TODO: Change to be dynamic in prod
    end

    def gpo_graphic
      @gpo_graphic ||= GpoGraphic.find_by_identifier(image_identifier)
    end

    def gpo_graphic?
      gpo_graphic.present?
    end

    def create_graphic_usage
      GpoGraphicUsage.create(
        :identifier => image_identifier,
        :document_number => document_number
      )
    end

    def copy_to_public_bucket
      directory = fog_aws_connection.directories.get(
        private_bucket,
        :prefix => image_identifier
      )
      directory.files.each do |file|
        file.copy(public_bucket, file.key)
      end
    end

  end

  private

  def process_documents
    XML_IMAGE_TAGS.each do |xml_tag|
      document_graphics(xml_tag).each do |document_graphic|
        if document_graphic.gpo_graphic?
          document_graphic.copy_to_public_bucket
        else
          GpoGraphic.create(:identifier => document_graphic.image_identifier)
        end
        document_graphic.create_graphic_usage
      end
    end
  end

  def document_graphics(xml_tag)
    documents.each_with_object([]) do |document, document_graphics|
      xml_doc = Nokogiri::XML(document.full_xml)
      xml_doc.css(xml_tag).each do |node|
        document_graphics << DocumentGraphic.new(node.text, document.document_number)
      end
    end
  end

end
