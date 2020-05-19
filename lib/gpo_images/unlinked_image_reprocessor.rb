module GpoImages
  class UnlinkedImageReprocessor
    extend Memoist

    def self.perform
      new.perform
    end

    MAX_DOCUMENTS = 2000
    def perform
      check_document_limit!
      GpoImages::DailyIssueImageProcessor.new(nil, documents_for_rescanning.first(MAX_DOCUMENTS)).perform
    end


    private

    def check_document_limit!
      if documents_for_rescanning.count > MAX_DOCUMENTS
        Honeybadger.notify("More than #{MAX_DOCUMENTS} documents were identified for rescanning.  Only the first #{MAX_DOCUMENTS} will be processed.")
      end
    end

    def documents_for_rescanning
      GpoGraphic.
        left_joins(:gpo_graphic_usages).
        where("gpo_graphic_usages.identifier IS NULL").
        where.not(graphic_file_name: nil).
        each_with_object(Array.new) do |gpo_graphic, documents|
          EntrySearch.new(
            conditions: {
              term: gpo_graphic.identifier,
              publication_date: {
                gte: GpoImages::DailyIssueImageProcessor::GPO_IMAGE_START_DATE,
              }
            },
            metadata_only: true
          ).
          results.
          each {|document| documents << document}
        end
    end
    memoize :documents_for_rescanning

  end
end
