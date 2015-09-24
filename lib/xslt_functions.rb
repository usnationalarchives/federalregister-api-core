class XsltFunctions
  include GpoImages::ImageIdentifierNormalizer

  def gpo_image(nodes, link_id, extracted_images, processed_images)
    document = blank_document

    extracted_images = extracted_images.split(',')
    graphic_identifier = normalize_image_identifier(
      nodes.first.content
    )
    processed_images = processed_images.split(',')

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.a(
        :class => "entry_graphic_link",
        :id => link_id,
        :href => graphic_url('original', graphic_identifier, extracted_images, processed_images)
      ) {
        doc.img(
          :class => 'entry_graphic',
          :src => graphic_url('large', graphic_identifier, extracted_images, processed_images)
        )
      }
    end

    document.children
  end

  def capitalize(nodes)
    nodes.first.content.upcase
  end

  private

  def blank_document
    Nokogiri::XML::DocumentFragment.parse ""
  end

  def graphic_url(size, graphic_identifier, extracted_images, processed_images)
    if extracted_images.include?(graphic_identifier)
      "https://s3.amazonaws.com/#{SETTINGS["original_images_bucket"]}/#{graphic_identifier}/#{size}.png"
    elsif processed_images.include?(graphic_identifier)
      "https://s3.amazonaws.com/#{SETTINGS["public_processed_images_s3_bucket"]}/#{graphic_identifier}/#{size}.png"
    else
      "https://s3.amazonaws.com/#{SETTINGS["public_processed_images_s3_bucket"]}/missingimage/#{size}.png"
    end
  end
end
