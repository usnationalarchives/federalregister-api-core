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

  it "updates existent executive orders (normalizes CSV headers and ignores blank lines)" do
    entry = FactoryGirl.create(:entry)
    agency_name = FactoryGirl.create(:agency_name, name: 'Executive Office of the President')

    csv_rows = <<-eos.strip_heredoc
      citation,document_number,end_page,executive_order_notes,ExEcUtive_order_number  ,html_url,pdf_url,publication_date,signing_date,start_page,title
      59 FR 499,#{entry.document_number},499,,12890,https://www.federalregister.gov/documents/1994/01/05/94-290/amendment-to-executive-order-no-12864,https://www.govinfo.gov/content/pkg/FR-1994-01-05/html/94-290.htm,#{Date.current.to_s(:default)},12/30/93,499,Amendment to Executive Order No. 12864
      ,,,,,,,,,,
    eos
    csv_file = stubbed_csv(csv_rows)

    Content::ExecutiveOrderImporter.perform(csv_file.path)
    expect(Entry.first).to have_attributes(
      presidential_document_number: "12890"
    )
  end

end
