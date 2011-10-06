
require 'spec_helper'

def parse_html(html)
  parser = Nokogiri::HTML::SAX::Parser.new(Content::PublicInspectionImporter::Parser.new)
  parser.parse("<div id='content-body'>#{html}</div><div id='Footer'></div>")
  parser.document
end

describe Content::PublicInspectionImporter::Parser do
  context "basic case" do
    before(:each) do
      @html = <<-HTML
        <a name="special" />
        <p><b>BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT </b></p>
        <p><b>RULES</b></p>
        <p>Reorganization of Title 30:</p>
        <p>&nbsp;</p>
        <blockquote>Bureaus of Safety and Environmental Enforcement and Ocean Energy Management</blockquote>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22675<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
      HTML
    end

    it "extracts the filing_type" do
      parse_html(@html).pi_documents.first[:filing_type].should == 'special'
    end

    it "extracts the details" do
      parse_html(@html).pi_documents.first[:details].should == '[Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm; Publication Date: 10/18/2011]'
    end

    it "extracts the agency" do
      parse_html(@html).pi_documents.first[:agency].should == 'BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT'
    end

    it "extracts the granule_class" do
      parse_html(@html).pi_documents.first[:granule_class].should == 'RULE'
    end

    it "extracts the document_number" do
      parse_html(@html).pi_documents.first[:document_number].should == '2011-22675'
    end

    it "extracts the toc_subject" do
      parse_html(@html).pi_documents.first[:toc_subject].should == 'Reorganization of Title 30:'
    end

    it "extracts the toc_doc" do
      parse_html(@html).pi_documents.first[:toc_doc].should == 'Bureaus of Safety and Environmental Enforcement and Ocean Energy Management'
    end

    it "extracts the title" do
      parse_html(@html).pi_documents.first[:title].should == ''
    end

    it "extracts the url" do
      parse_html(@html).pi_documents.first[:url].should == 'http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf'
    end
  end

  context "multiple documents" do
    it "handles changes in agency" do
      html = <<-HTML
        <p><b>BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT </b></p>
        <p><b>RULES</b></p>
        <p>Reorganization of Title 30:</p>
        <p>&nbsp;</p>
        <blockquote>Bureaus of Safety and Environmental Enforcement and Ocean Energy Management</blockquote>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22675<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
        <p>&nbsp;</p>
        <p><b>Some other agency</b></p>
        <p><b>RULES</b></p>
        <p>Reorganization of Title 30:</p>
        <p>&nbsp;</p>
        <blockquote>Bureaus of Safety and Environmental Enforcement and Ocean Energy Management</blockquote>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22675<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
      HTML

      docs = parse_html(html).pi_documents
      docs[0][:agency].should == 'BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT'
      docs[1][:agency].should == 'Some other agency'
    end

    it "handles shared toc_subject" do
      html = <<-HTML
        <p><b>BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT </b></p>
        <p><b>RULES</b></p>
        <p>Reorganization of Title 30:</p>
        <p>&nbsp;</p>
        <blockquote>Bureaus of Safety and Environmental Enforcement and Ocean Energy Management</blockquote>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22675<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
        <p>&nbsp;</p>
        <blockquote>Some other topic</blockquote>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22676<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
      HTML
      docs = parse_html(html).pi_documents
      first = docs[0]
      second = docs[1]
      first[:document_number].should == '2011-22675'
      first[:toc_subject].should == 'Reorganization of Title 30:'
      first[:toc_doc].should == 'Bureaus of Safety and Environmental Enforcement and Ocean Energy Management'
      second[:document_number].should == '2011-22676'
      second[:toc_subject].should == 'Reorganization of Title 30:'
      second[:toc_doc].should == 'Some other topic'
    end

    it "handles shared toc_doc" do
      html = <<-HTML
        <p><b>BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT </b></p>
        <p><b>RULES</b></p>
        <p>Reorganization of Title 30:</p>
        <p>&nbsp;</p>
        <blockquote>Bureaus of Safety and Environmental Enforcement and Ocean Energy Management</blockquote>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22675<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-22676<a href="http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm;&nbsp;&nbsp;Publication Date: 10/18/2011]</blockquote>
      HTML
      docs = parse_html(html).pi_documents
      first = docs[0]
      second = docs[1]
      first[:document_number].should == '2011-22675'
      first[:toc_subject].should == 'Reorganization of Title 30:'
      first[:toc_doc].should == 'Bureaus of Safety and Environmental Enforcement and Ocean Energy Management'
      second[:document_number].should == '2011-22676'
      second[:toc_subject].should == 'Reorganization of Title 30:'
      second[:toc_doc].should == 'Bureaus of Safety and Environmental Enforcement and Ocean Energy Management'
    end
  end

  context 'presidential documents' do
    before(:each) do
      @html = <<-HTML
      <p><b>PRESIDENTIAL DOCUMENTS</b></p>
      <p><b>ADMINISTRATIVE ORDERS</b></p>
      <p>Aviation Insurance Coverage for Commercial Air Carrier Service in Domestic and International Operations (Memorandum of September 28, 2011)</p>
      <p>&nbsp;</p>
      <blockquote>&nbsp;2011-25649<a href="http://ofr.gov/OFRUpload/OFRData/2011-25649_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
      [Memo. of 9/28/2011; Filed: 09/30/11 at 11:15am;&nbsp;&nbsp;Publication Date: 10/3/2011]</blockquote>
      HTML
    end

    it "sets the agency correctly" do
      parse_html(@html).pi_documents.first[:agency] == 'Executive Office of the President'
    end

    it "ignores the presidential document type" do
      parse_html(@html).pi_documents.first[:granule_class] == 'PRESDOCU'
    end

    it "sets the title correctly" do
      parse_html(@html).pi_documents.first[:granule_class] == 'Aviation Insurance Coverage for Commercial Air Carrier Service in Domestic and International Operations (Memorandum of September 28, 2011)'
    end
  end

  context "editorial notes" do
    it "should associate the note with the proper document" do
      html = <<-HTML
        <p><b>FEDERAL ELECTION COMMISSION</b></p>
        <p><b>RULES</b></p>
        <p>Publicly Disseminated Independent Expenditures</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-24871<a href="http://ofr.gov/OFRUpload/OFRData/2011-24871_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Notice 2011-13; Filed: 09/29/11 at 8:45 am]</blockquote>
        <p>&nbsp;</p>
        <b>EDITORIAL NOTE:</b> The Federal Election Commission has requested this document be withdrawn from publication. This document will remain on-file through close of business on September 30, 2011. A copy of the agency's letter is available for inspection at the Office of the Federal Register.
        <p><b>NOTICES</b></p>
        <p>Meetings; Sunshine Act</p>
        <p>&nbsp;</p>
        <blockquote>&nbsp;2011-25592<a href="http://ofr.gov/OFRUpload/OFRData/2011-25592_PI.pdf" target="_blank"> <img title="View Pdf" style="border: 0px solid;" alt="View Pdf" src="./2011-10-02_files/pfdlggif.gif"></a><br>
        [Filed: 09/29/11 at 4:15pm;&nbsp;&nbsp;Publication Date: 10/3/2011]</blockquote>
      HTML
      docs = parse_html(html).pi_documents
      docs.first[:editorial_note].should == "The Federal Election Commission has requested this document be withdrawn from publication. This document will remain on-file through close of business on September 30, 2011. A copy of the agency's letter is available for inspection at the Office of the Federal Register."
      docs.first[:document_number].should == '2011-24871'
      docs.second[:editorial_note].should be_nil
      docs.second[:document_number].should == '2011-25592'
    end
  end

  describe '#special_filings_updated_at' do
    it "parses the special filing updated time" do
      html = <<-HTML
        <p style="background-color: #fefefe; font-family: arial; color: black; font-size: 12px;"><b>Note: This Special Filing List was updated at 11:15 a.m., Friday, September 30, 2011.</b>&nbsp;&nbsp;The following documents are on file for public inspection and will publish in the FEDERAL REGISTER on the date listed.</p>
        <p style="background-color: #fefefe; font-family: arial; color: black; font-size: 12px;"><b>Note: This Regular Filing List was updated at 8:15 a.m., Friday, September 30, 2011.</b>&nbsp;&nbsp;The following documents are on file for public inspection and will publish in the FEDERAL REGISTER on the date listed.</p>
      HTML
      parse_html(html).special_filings_updated_at.should == Time.zone.parse("2011-09-30 11:15:00")
    end
  end

  describe '#regular_filings_updated_at' do
    it "parses the regular filing updated time" do
      html = <<-HTML
        <p style="background-color: #fefefe; font-family: arial; color: black; font-size: 12px;"><b>Note: This Special Filing List was updated at 11:15 a.m., Friday, September 30, 2011.</b>&nbsp;&nbsp;The following documents are on file for public inspection and will publish in the FEDERAL REGISTER on the date listed.</p>
        <p style="background-color: #fefefe; font-family: arial; color: black; font-size: 12px;"><b>Note: This Regular Filing List was updated at 8:15 a.m., Friday, September 30, 2011.</b>&nbsp;&nbsp;The following documents are on file for public inspection and will publish in the FEDERAL REGISTER on the date listed.</p>
      HTML
      parse_html(html).regular_filings_updated_at.should == Time.zone.parse("2011-09-30 8:15:00")
    end

  end
end
