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
    entry = FactoryGirl.create(:entry)
    csv_rows = <<-eos.strip_heredoc
      citation,document_number,end_page,executive_order_notes,ExEcUtive_order_number  ,html_url,pdf_url,publication_date,signing_date,start_page,title
      59 FR 499,   #{entry.document_number} ,499,,12890,https://www.federalregister.gov/documents/1994/01/05/94-290/amendment-to-executive-order-no-12864,https://www.govinfo.gov/content/pkg/FR-1994-01-05/html/94-290.htm,#{Date.new(1900,1,1).to_s(:default)},12/30/93,499,Amendment to Executive Order No. 12864
      ,,,,,,,,,,
    eos
    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.first).to have_attributes(
      presidential_document_number: "12890"
    )
  end

end
