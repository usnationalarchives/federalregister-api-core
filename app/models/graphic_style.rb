class GraphicStyle < ApplicationModel
  belongs_to :styleable, polymorphic: true, foreign_type: :graphic_type, foreign_key: :graphic_id

  def url
    styleable.graphic.styles.values.first.attachment
  end

end
