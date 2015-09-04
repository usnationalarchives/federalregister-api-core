require 'ruby-debug'

class MissingImagesPresenter
  attr_reader :graphic_usages

  def initialize
    @graphic_usages ||= GpoGraphic.all(:conditions=>"graphic_file_name IS NULL").map do |gpo_graphic|
      gpo_graphic.gpo_graphic_usages
    end.
    flatten
  end

  def missing_image_date_data
    graphic_usages.group_by{|gu|gu.entry.publication_date}.map do |date, graphic_usages|
      DateData.new(date, graphic_usages)
    end
  end

  class DateData
    attr_reader :date, :graphic_usages, :graphic_usages_by_document

    def initialize(date, graphic_usages)
      @date = date
      @graphic_usages = graphic_usages
    end

    def documents
      graphic_usages_by_document.map do |document_number, graphic_usages|
        document = OpenStruct.new
        document.document_number = document_number
        document.image_identifiers = graphic_usages.map{|gu|gu.identifier}
        document
      end
    end

    def graphic_usages_by_document
      @graphic_usages_by_document ||= graphic_usages.group_by{|gu| gu.document_number}
    end

  end

end

# missing_images = GpoGraphic.all(:conditions=>"graphic_file_name IS NULL").map do |gpo_graphic|
#   gpo_graphic.gpo_graphic_usages
# end.
# flatten.
# group_by{|d|d.document_number}
