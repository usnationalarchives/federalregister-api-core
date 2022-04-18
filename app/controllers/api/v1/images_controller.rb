class Api::V1::ImagesController < ApiController

  def show
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
    gpo_graphic = graphic_styles.first.styleable
    image_source = gpo_graphic.sourced_via_ecfr_dot_gov ? "Retired ECFR.gov" : "GPO SFTP"

    graphic_styles.each_with_object(Hash.new) do |graphic_style, hsh|
      hsh[graphic_style.style_name] = {
        height: graphic_style.height,
        image_format: graphic_style.image_format,
        image_source: image_source,
        url:    graphic_style.url,
        width:  graphic_style.width,
      }
    end
  end

  def publicly_accessible?(graphic_styles)
    graphic_styles.first.public?
  end

end
