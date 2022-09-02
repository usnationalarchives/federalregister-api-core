class DailyIssueImageUsageBuilder
  include Sidekiq::Worker
  include GpoImages::ImageIdentifierNormalizer

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(date, documents=nil)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @documents = documents || Entry.where(publication_date: @date.to_s(:iso))
    scan_documents_for_images
  end

  private

  attr_reader :date, :documents

  def scan_documents_for_images
    entry_ids_for_reindexing = []
    GpoImages::DailyIssueImageProcessor::XML_IMAGE_TAGS.each do |xml_tag|
      image_usages(xml_tag).each do |attributes|
        image_usage = ImageUsage.find_or_initialize_by(
          document_number:  attributes.document_number,
          identifier: attributes.identifier
        )
        entry_ids_for_reindexing << attributes.entry_id
        image_usage.xml_identifier = attributes.xml_identifier
        image_usage.save!
        image = image_usage.image
        if image.present?
          image.make_public!
        else
          Image.create!(
            created_at:       image_usage.updated_at,
            image_file_name:  nil,
            identifier:       image_usage.identifier,
            updated_at:       image_usage.updated_at,
            made_public_at:   Time.current
          )
        end
      end
    end

    #Reindex ES
    if entry_ids_for_reindexing.present?
      EntryChange.upsert_all(entry_ids_for_reindexing.uniq.map{|id| {entry_id: id} })
    end
    ElasticsearchIndexer.handle_entry_changes
  end

  def image_usages(xml_tag)
    documents.each_with_object([]) do |document, image_usages|
      puts "missing xml for #{document.document_number}" unless document.full_xml.present?

      xml_doc = Nokogiri::XML(document.full_xml)
      xml_doc.css(xml_tag).each do |node|
        image_usages << OpenStruct.new(
          entry_id: document.id,
          identifier: normalized_identifier(node.text),
          document_number: document.document_number,
          xml_identifier: node.text
        )
      end
    end
  end

  private

  def normalized_identifier(identifier)
    normalize_image_identifier(identifier)
  end

end
