class Api::V1::ImagesController < ApiController

  def show
    cache_for 1.day
    graphic_styles = GraphicStyle.
      includes(styleable: :gpo_graphic_usages).
      where(image_identifier: params[:id].try(:downcase))

    if graphic_styles.present? && publicly_accessible?(graphic_styles)
      render_json_or_jsonp image_json(graphic_styles)
    else
      render json: {}, status: 404
    end
  end

  private

  def image_json(graphic_styles)
    graphic_styles.each_with_object(Hash.new) do |graphic_style, hsh|
      hsh[graphic_style.style_name] = {
        url:    graphic_style.url,
        height: graphic_style.height,
        width:  graphic_style.width
      }
    end
  end

  def publicly_accessible?(graphic_styles)
    graphic_styles.first.public?
  end

end
