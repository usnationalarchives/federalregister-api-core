class GraphicStyleUpdater
  include Sidekiq::Worker

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(gpo_graphic_id)
    GpoGraphic.find(gpo_graphic_id).update_graphic_styles
  end

end
