class MissingImagesPresenter
  extend Memoist

  def dates_missing_images
    usages.
      sort_by{|gu| gu.entry.publication_date}.
      group_by{|gu| gu.entry.publication_date}.
      map do |date, graphic_usages|
        DateData.new(date, graphic_usages)
      end
  end

  def usages
    image_usages
  end

  private

  def gpo_graphic_usages
    GpoGraphic.
      unprocessed.
      includes(:gpo_graphic_usages).
      map do |gpo_graphic|
        gpo_graphic.gpo_graphic_usages
      end.
      flatten
  end
  memoize :gpo_graphic_usages

  CUTOFF_PERIOD = 3.months
  def image_usages
    ImageUsage.
      joins("LEFT JOIN image_variants ON image_variants.identifier = image_usages.identifier AND image_variants.style = 'original_size'").
      joins("LEFT JOIN entries ON entries.document_number = image_usages.document_number").
      where("entries.publication_date > ?", (Date.current - CUTOFF_PERIOD).to_s(:iso)).
      where("image_variants.id IS NULL")
  end
  memoize :image_usages

  class DateData
    attr_reader :date
    extend Memoist

    def initialize(date, usages)
      @date   = date
      @usages = usages
    end

    def documents
      usages_by_document.map do |document_number, usages|
        document = OpenStruct.new(
          :document_number   => document_number,
          :usages            => usages
        )
        document
      end
    end

    def usages_by_document
      usages.
        group_by{|gu| gu.document_number}
    end
    memoize :usages_by_document

    private

    attr_reader :usages
  end

end
