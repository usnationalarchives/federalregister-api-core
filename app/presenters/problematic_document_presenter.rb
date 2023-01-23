class ProblematicDocumentPresenter
  delegate :publication_date, :to => :issue
  attr_reader :issue, :date
  extend Memoist

  def initialize(date)
    @issue = Issue.find_by_publication_date!(date)
    @date = date
  end

  def special_documents
    @special_documents ||= issue.
      entries.
      select {|doc| doc.document_number.match(/^X/)}
  end

  def documents_present_in_xml_but_not_in_toc
    xml_document_numbers - toc_document_numbers
  end

  def documents_present_in_toc_but_not_in_xml
    toc_document_numbers - xml_document_numbers
  end

  def documents_scheduled_but_unpublished
    PublicInspectionDocument.
      joins("LEFT OUTER JOIN entries ON entries.id = public_inspection_documents.entry_id").
      where(
        :public_inspection_documents => {
          :publication_date => date
        },
        :entries => {
          :id => nil
        }
      )
  end

  def revoked_and_published_documents
    published_doc_numbers = Entry.where(publication_date: date).map(&:document_number)

    PublicInspectionDocument.where(
      document_number:  published_doc_numbers,
      publication_date: nil
    )
  end

  def documents_published_without_public_inspection
    Entry.
      joins("LEFT OUTER JOIN public_inspection_documents on public_inspection_documents.document_number = entries.document_number").
      where(
        :entries => {
          :publication_date => date
        },
        :public_inspection_documents => {
          :id => nil
        }
      )
  end

  def rules_with_date_text
    rules.each_with_object({}) do |doc, hsh|

      date_text, extracted_dates = extract_dates(doc, date)

      hsh[doc.document_number] = highlight_dates(
        extracted_dates,
        doc.effective_on,
        date_text
      )
    end
  end

  def proposed_rules_with_date_text
    proposed_rules.each_with_object({}) do |doc, hsh|

      date_text, extracted_dates = extract_dates(doc, date)

      hsh[doc.document_number] = highlight_dates(
        extracted_dates,
        doc.comments_close_on,
        date_text
      )
    end
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
          hsh[doc.document_number] = highlight_dates(
            extracted_dates,
            doc.comments_close_on,
            date_text
          )
        end
      end
    end
  end

  def link_images_if_original?
    missing_images_presenter.link_images_if_original?
  end

  def missing_gpo_graphics
    missing_images_presenter.dates_missing_images.find{|d| d.date == date}
  end

  def missing_executive_orders
    missing_presidential_documents(PresidentialDocumentType::EXECUTIVE_ORDER)
  end
  memoize :missing_executive_orders

  def missing_presidential_proclamations
    missing_presidential_documents(PresidentialDocumentType::PROCLAMATION)
  end
  memoize :missing_presidential_proclamations

  private

  def missing_presidential_documents(presidential_document_type)
    expected_presidential_document_numbers = presidential_document_numbers(presidential_document_type)

    if expected_presidential_document_numbers.blank?
      return []
    else
      ((expected_presidential_document_numbers.min..expected_presidential_document_numbers.max).to_a - expected_presidential_document_numbers).reverse
    end
  end

  def presidential_document_numbers(presidential_document_type)
    Entry.
      where(presidential_document_type_id: presidential_document_type.id).
      where.not(presidential_document_number: nil).
      where("publication_date >= '1994-01-01'"). #This clause can be deleted if historical docs are populated
      select("CAST(presidential_document_number AS UNSIGNED) AS pres_doc_number").
      map(&:pres_doc_number)
  end
  memoize :presidential_document_numbers

  def missing_images_presenter
    MissingImagesPresenter.new
  end

  def rules
    @rules_without_dates ||= issue.
      entries.
      select do |doc|
        doc.granule_class == "RULE" &&
        !doc.document_number.match(/^C-/)
      end
  end

  def proposed_rules
    @proposed_rules_without_dates ||= issue.
      entries.
      select do |doc|
        doc.granule_class == "PRORULE" &&
        !doc.document_number.match(/^C-/)
      end
  end

  def extract_dates(doc, date)
    mods_node = Content::EntryImporter::ModsFile.new(date, false).
      find_entry_node_by_document_number(doc.document_number)
    date_text = mods_node.css('dates').first.try(:content)
    extracted_dates = PotentialDateExtractor.extract(date_text)

    return date_text, extracted_dates
  end

  def highlight_dates(extracted_dates, date_to_highlight, date_text)
    extracted_dates.each do |extracted_date|
      date_text.gsub!(extracted_date) do |date|
        begin
          if date.to_date == date_to_highlight
            "<span style='color: red; font-weight: bold'>#{date}</span>"
          else
            "<span style='font-weight: bold;'>#{date}</span>"
          end
        rescue #usually a string that looks like a date but isn't a valid date
          "<span style='font-weight: bold;'>#{date}</span>"
        end
      end
    end

    date_text
  end

  def xml_document_numbers
    issue.entries.map(&:document_number)
  end

  def toc_document_numbers
    Array.new.tap do |doc_numbers|
      toc_json['agencies'].each do |agency_hsh|
        agency_hsh['document_categories'].each do |document_category_hsh|
          document_category_hsh['documents'].each do |documents_hsh|
            documents_hsh['document_numbers'].each do |document_number|
              doc_numbers << document_number
            end
          end
        end
      end
    end
  end

  def toc_json
    JSON.parse(toc_json_file_contents)
  end

  def toc_json_file_contents
    File.read(FileSystemPathManager.new(date).document_issue_json_toc_path)
  end


end
