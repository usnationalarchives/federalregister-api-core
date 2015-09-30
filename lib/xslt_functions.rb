class XsltFunctions
  include GpoImages::ImageIdentifierNormalizer

  def gpo_image(nodes, link_id, identifiers)
    document = blank_document

    identifiers = identifiers.split(',')
    graphic_identifier = normalize_image_identifier(
      nodes.first.content
    )

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.a(
        :class => "entry_graphic_link",
        :id => link_id,
        :href => graphic_url('original', graphic_identifier, identifiers)
      ) {
        doc.img(
          :class => 'entry_graphic',
          :src => graphic_url('large', graphic_identifier, identifiers)
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

  def graphic_url(size, graphic_identifier, identifiers)
    if identifiers.include?(graphic_identifier)
      "https://s3.amazonaws.com/#{SETTINGS["s3_buckets"]["public_images"]}/#{graphic_identifier}/#{size}.png"
    else
      "https://s3.amazonaws.com/#{SETTINGS["s3_buckets"]["public_images"]}/missingimage/#{size}.png"
    end
  end
end
