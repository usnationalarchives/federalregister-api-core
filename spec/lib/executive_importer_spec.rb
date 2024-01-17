require "spec_helper"

def stubbed_csv(csv_text, tempfile_name="arbitrary.csv", options = {empty_endline: true})
  if options.fetch(:empty_endline)
    endline_handling_method = :itself
  else
    endline_handling_method = :chomp
  end

  csv_file = Tempfile.new([tempfile_name, ".csv"])
  csv_file.write(csv_text.strip_heredoc.send(endline_handling_method))
  csv_file.rewind
  csv_file
end

describe "ExecutiveOrderImporter" do
  before(:each) do
    agency_name = FactoryGirl.create(:agency_name, name: 'Executive Office of the President')
  end

  it "updates existent executive orders (normalizes CSV headers, strips document number/publication date, and ignores blank lines)" do
    entry = FactoryGirl.create(:entry)
    csv_rows = <<-eos.strip_heredoc
      citation,document_number,end_page,executive_order_notes,ExEcUtive_order_number  ,html_url,pdf_url,publication_date,signing_date,start_page,title
      59 FR 499,   #{entry.document_number} ,499,,12890,https://www.federalregister.gov/documents/1994/01/05/94-290/amendment-to-executive-order-no-12864,https://www.govinfo.gov/content/pkg/FR-1994-01-05/html/94-290.htm,#{entry.publication_date.to_s(:default)},12/30/93,499,Amendment to Executive Order No. 12864
      ,,,,,,,,,,
    eos
    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.first).to have_attributes(
      presidential_document_number: "12890"
    )
  end

  it "prioritizes publication date if available" do
    #NOTE: 96-2755 is an example of a duplicate document number
    entry_2 = FactoryGirl.create(:entry, document_number: '96-2755', publication_date: Date.new(1996,2,9))
    entry_1 = FactoryGirl.create(:entry, document_number: '96-2755', publication_date: Date.new(1996,2,7))
    csv_rows = <<-eos.strip_heredoc
      citation,document_number,end_page,executive_order_notes,ExEcUtive_order_number  ,html_url,pdf_url,publication_date,signing_date,start_page,title
      59 FR 499,96-2755,499,,12988,https://www.federalregister.gov/documents/1994/01/05/94-290/amendment-to-executive-order-no-12864,https://www.govinfo.gov/content/pkg/FR-1994-01-05/html/94-290.htm,#{Date.new(1996,2,7).to_s(:default)},12/30/93,499,Amendment to Executive Order No. 12864
      ,,,,,,,,,,
    eos
    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(entry_1.reload).to have_attributes(
      presidential_document_number: "12988"
    )
  end

  it "prioritizes updating an executive order number even if it's publication date does not match what we have stored in the DB for an entry" do
    entry = FactoryGirl.create(:entry, presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id, presidential_document_number: "12890", publication_date: Date.new(1994,1,5))
    csv_rows = <<-eos.strip_heredoc
      citation,document_number,end_page,executive_order_notes,ExEcUtive_order_number  ,html_url,pdf_url,publication_date,signing_date,start_page,title
      59 FR 499,   #{entry.document_number} ,499,,12890,https://www.federalregister.gov/documents/1994/01/05/94-290/amendment-to-executive-order-no-12864,https://www.govinfo.gov/content/pkg/FR-1994-01-05/html/94-290.htm,#{Date.new(1900,1,1).to_s(:default)},12/30/93,499,Amendment to Executive Order No. 12864
      ,,,,,,,,,,
    eos
    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.count).to eq(1)
    expect(Entry.first.reload).to have_attributes(
      presidential_document_number: "12890"
    )
  end

  it "If an EO number occurs before #{Content::ExecutiveOrderImporter::HISTORICAL_EO_NUMBER_CUTOFF} and it does not yet exist, import it" do
    csv_rows = <<-eos.strip_heredoc
      title,citation,executive_order_number,signing_date_string,signing_date,publication_date_string,publication_date,president,disposition_notes,scraped_url
      "Amending Executive Order 8396 of April 18, 1940, Prescribing Chapter I of the Foreign Service Regulations of the United States",10 FR 4010,9537,"April 11, 1945 ",1945-04-11," April 14, 1945",1945-04-14,roosevelt,"Amends: EO 8396, April 18, 1940",https://www.archives.gov/federal-register/executive-orders/1945-roosevelt.html
    eos

    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.first).to have_attributes(
      citation: '10 FR 4010',
      presidential_document_number: "9537",
      publication_date: Date.new(1945,4,14),
      signing_date: Date.new(1945,4,11),
      title: "Amending Executive Order 8396 of April 18, 1940, Prescribing Chapter I of the Foreign Service Regulations of the United States",
      executive_order_notes: "Amends: EO 8396, April 18, 1940"
    )
  end

  it "does not update the signing date/publication_date if it appears to be outside a reasonable timeframe" do
    '10575-09-20'
    csv_rows = <<-eos.strip_heredoc
      title,citation,executive_order_number,signing_date_string,signing_date,publication_date_string,publication_date,president,disposition_notes,scraped_url
      "Amending Executive Order 8396 of April 18, 1940, Prescribing Chapter I of the Foreign Service Regulations of the United States",10 FR 4010,9537,"April 11, 1945 ",19656-04-11," April 14, 1945",10575-09-20,roosevelt,"Amends: EO 8396, April 18, 1940",https://www.archives.gov/federal-register/executive-orders/1945-roosevelt.html
    eos

    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.first).to have_attributes(
      signing_date: nil,
      publication_date: nil
    )
  end

  it "populates not received for publication when the publication_date field is 'not_received_for_publication'" do
    csv_rows = <<-eos.strip_heredoc
      title,citation,executive_order_number,signing_date_string,signing_date,publication_date_string,publication_date,president,disposition_notes,scraped_url
      Korea,not_received_for_publication,10026-A,"January 5, 1949",1949-01-05,not_received_for_publication,not_received_for_publication,truman,"",https://www.archives.gov/federal-register/executive-orders/1949.html
    eos

    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.first).to have_attributes(
      citation: nil,
      not_received_for_publication: true
    )
  end

end
