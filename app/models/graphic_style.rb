class GraphicStyle < ApplicationModel
  belongs_to :styleable, polymorphic: true, foreign_type: :graphic_type, foreign_key: :graphic_id

  def self.recalculate_all!
    GraphicStyle.delete_all
    GpoGraphic.find_each do |gpo_graphic|
      gpo_graphic.update_graphic_styles
    end
  end

  def url
    styleable.graphic.styles.values.first.attachment.url(style_name, timestamp: false)
  end

  def public?
    styleable.public?
  end

  def entry_api_representation_style_name
    if style_name == 'original_png'
      'original'
    else
      style_name
    end
  end

end
