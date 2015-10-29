class MissingImagesPresenter
  def dates_missing_images
    graphic_usages.
      sort_by{|gu| gu.entry.publication_date}.
      group_by{|gu| gu.entry.publication_date}.
      map do |date, graphic_usages|
        DateData.new(date, graphic_usages)
      end
  end

  def graphic_usages
    @graphic_usages ||= GpoGraphic.unprocessed.
      map do |gpo_graphic|
        gpo_graphic.gpo_graphic_usages
      end.
      flatten
  end

  class DateData
    attr_reader :date, :graphic_usages

    def initialize(date, graphic_usages)
      @date = date
      @graphic_usages = graphic_usages
    end

    def documents
      graphic_usages_by_document.map do |document_number, graphic_usages|
        document = OpenStruct.new(
          :document_number => document_number,
          :image_identifiers => graphic_usages.map{|gu| gu.identifier}
        )
        document
      end
    end

    def graphic_usages_by_document
      @graphic_usages_by_document ||= graphic_usages.
        group_by{|gu| gu.document_number}
    end
  end

end
