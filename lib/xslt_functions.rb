class XsltFunctions
  include GpoImages::ImageIdentifierNormalizer

  def gpo_image(nodes, link_id)
    document = blank_document

    graphic_identifier = URI.encode(nodes.first.content)

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.a(
        :class => "entry_graphic_link",
        :id => link_id,
        :href => graphic_url('original', graphic_identifier)
      ) {
        doc.img(
          :class => 'entry_graphic',
          :src => graphic_url('large', graphic_identifier)
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

  def graphic_url(size, graphic_identifier)
    "https://s3.amazonaws.com/#{SETTINGS["s3_buckets"]["public_images"]}/#{graphic_identifier}/#{size}.png"
  end
end
