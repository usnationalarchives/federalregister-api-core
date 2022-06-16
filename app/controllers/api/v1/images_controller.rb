class Api::V1::ImagesController < ApiController

  def show
    image = Image.
      find_by(identifier: params[:id].try(:upcase))
    image_variants = image.try(:image_variants)

    if image_variants.present? && image.made_public_at?
      render_json_or_jsonp image_json(image_variants)
    else
      render json: {}, status: 404
    end
  end

  private

  def image_json(image_variants)
    image = image_variants.first.original_image
    image_variants.each_with_object(Hash.new) do |image_variant, hsh|
      hsh[image_variant.style] = {
        content_type: image_variant.image_content_type,
        height:       image_variant.image_height,
        image_source: image.image_source.try(:identifier) || 'Unknown',
        sha:          image_variant.image_sha,
        size:         image_variant.image_size,
        url:          image_variant.image.url,
        width:        image_variant.image_width,
      }
    end
  end

end
