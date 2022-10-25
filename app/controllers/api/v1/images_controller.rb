class Api::V1::ImagesController < ApiController

  def show
    respond_to do |wants|
      wants.json do
        image = Image.
          find_by(identifier: image_identifier)
        image_variants = image.try(:image_variants)

        if image_variants.present? && image.made_public_at?
          render_json_or_jsonp image_json(image_variants)
        else
          render json: {}, status: 404
        end
      end
    end
  end

  private

  def image_identifier
    params[:id].try(:upcase).gsub(".JSON","")
  end

  def image_json(image_variants)
    image = image_variants.first.original_image
    image_variants.each_with_object(Hash.new) do |image_variant, hsh|
      hsh[image_variant.style] = {
        content_type: image_variant.image_content_type,
        height:       image_variant.image_height,
        identifier:   image_variant.identifier,
        image_source: image.image_source.try(:identifier) || 'Unknown',
        sha:          image_variant.image_sha,
        size:         image_variant.image_size,
        url:          "https://#{image_variant.image.url}",
        width:        image_variant.image_width,
      }
    end
  end

end
