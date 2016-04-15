class ProblematicDocumentPresenter
  delegate :publication_date, :to => :issue
  attr_reader :issue, :date

  def initialize(date)
    @issue = Issue.find_by_publication_date!(date)
    @date = date
  end

  def special_documents
    @special_documents ||= issue.
      entries.
      select {|doc| doc.document_number.match(/^X/)}
  end

  def rules_without_dates
    @rules_without_dates ||= issue.
      entries.
      select do |doc|
        doc.granule_class == "RULE" &&
        doc.effective_on.blank? &&
        !doc.document_number.match(/^C-/)
      end
  end

  def documents_scheduled_but_unpublished
    PublicInspectionDocument.all(
      :joins => "LEFT OUTER JOIN entries ON entries.id = public_inspection_documents.entry_id",
      :conditions => {
        :public_inspection_documents => {
          :publication_date => date
        },
        :entries => {
          :id => nil
        }
      }
    )
  end

  def revoked_and_published_documents
    previous_publication_date = issue.previous.publication_date
    revoked_pi_numbers =
      PublicInspectionIssue.
      find_by_publication_date(previous_publication_date).
      public_inspection_documents.
      revoked.
      map(&:document_number)
    published_doc_numbers =
      Entry.all(
        :conditions => {
          :publication_date => date
        }
      ).
      map(&:document_number)

    revoked_pi_numbers.
      select{|doc_number| published_doc_numbers.include? doc_number}.
      map{|doc_number| PublicInspectionDocument.find_by_document_number(doc_number) }
  end

  def documents_published_without_public_inspection
    Entry.all(
      :joins => "LEFT OUTER JOIN public_inspection_documents on public_inspection_documents.entry_id = entries.id",
      :conditions => {
        :entries => {
          :publication_date => date
        },
        :public_inspection_documents => {
          :id => nil
        }
      }
    )
  end

  def multiple_comment_dates
    issue.entries.each_with_object({}) do |doc, hsh|
      mods_node = Content::EntryImporter::ModsFile.new(date, false).
        find_entry_node_by_document_number(doc.document_number)
      comment_date = mods_node.css("commentDate").first
      if comment_date.present?
        date_text = mods_node.css('dates').first.try(:content)
        extracted_dates = PotentialDateExtractor.extract(date_text)
        if extracted_dates.uniq.size > 1
          extracted_dates.each do |extracted_date|
            date_text.gsub!(extracted_date) do |date|
              if date.to_date == doc.comments_close_on
                "<span style='color: red; font-weight: bold'>#{date}</span>"
              else
                "<span style='font-weight: bold;'>#{date}</span>"
              end
            end
          end
          hsh[doc.document_number] = date_text
        end
      end
    end
  end

  def missing_gpo_graphics
    MissingImagesPresenter.new.dates_missing_images.find{|d| d.date == date}
  end

end
