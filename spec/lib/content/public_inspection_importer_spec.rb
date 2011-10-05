
require 'spec_helper'

def parse_html(html)
  parser = Nokogiri::HTML::SAX::Parser.new(Content::PublicInspectionImporter::Parser.new)
  parser.parse("<div id='content-body'>#{html}</div><div id='Footer'></div>")
  parser.document.pi_documents
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
      parse_html(@html).first[:filing_type].should == 'special'
    end

    it "extracts the details" do
      parse_html(@html).first[:details].should == '[Docket ID: BOEM-2011-0070; Filed: 09/29/11 at 12:00pm; Publication Date: 10/18/2011]'
    end

    it "extracts the agency" do
      parse_html(@html).first[:agency].should == 'BUREAU OF SAFETY AND ENVIRONMENTAL ENFORCEMENT'
    end

    it "extracts the granule_class" do
      parse_html(@html).first[:granule_class].should == 'RULE'
    end

    it "extracts the document_number" do
      parse_html(@html).first[:document_number].should == '2011-22675'
    end

    it "extracts the toc_subject" do
      parse_html(@html).first[:toc_subject].should == 'Reorganization of Title 30:'
    end

    it "extracts the toc_doc" do
      parse_html(@html).first[:toc_doc].should == 'Bureaus of Safety and Environmental Enforcement and Ocean Energy Management'
    end

    it "extracts the title" do
      parse_html(@html).first[:title].should == ''
    end

    it "extracts the url" do
      parse_html(@html).first[:url].should == 'http://ofr.gov/OFRUpload/OFRData/2011-22675_PI.pdf'
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

      docs = parse_html(html)
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
      docs = parse_html(html)
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
      docs = parse_html(html)
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
      parse_html(@html).first[:agency] == 'Executive Office of the President'
    end

    it "ignores the presidential document type" do
      parse_html(@html).first[:granule_class] == 'PRESDOCU'
    end

    it "sets the title correctly" do
      parse_html(@html).first[:granule_class] == 'Aviation Insurance Coverage for Commercial Air Carrier Service in Domestic and International Operations (Memorandum of September 28, 2011)'
    end
  end
end
