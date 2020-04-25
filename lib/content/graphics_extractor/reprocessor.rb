module Content
  class GraphicsExtractor
    class Reprocessor

      def self.perform
        Graphic.
          left_joins(:entries).
          group("publication_date").
          select("publication_date, GROUP_CONCAT(graphics.id) AS graphic_ids").
          order("publication_date ASC").
          each do |grouped_row|
            puts "Processing #{grouped_row.publication_date}: graphic ids: #{grouped_row.graphic_ids}"
            graphic_ids                = grouped_row.graphic_ids.split(',')
            graphics_with_broken_links = []
            Graphic.where(id: graphic_ids).each do |graphic|
              url = graphic.graphic.url
              response = Faraday.head(url)
              if response.status != 200
                graphics_with_broken_links << graphic
              end
            end

            ApplicationModel.transaction do
              graphics_with_broken_links.each do |graphic|
                  graphic.graphic.destroy
                  graphic.save
                end
              end

              extractor = Content::GraphicsExtractor.new(grouped_row.publication_date)
              extractor.perform
            end
          end
      end

    end
  end
end
