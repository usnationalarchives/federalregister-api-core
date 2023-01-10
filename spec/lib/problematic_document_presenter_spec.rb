require 'spec_helper'

describe ProblematicDocumentPresenter do
  let(:toc_json) {
    <<-JSON
      {
        "agencies": [
          {
            "name": "Veterans Affairs Department",
            "slug": "veterans-affairs-department",
            "document_categories": [
              {
                "type": "Notice",
                "documents": [
                  {
                    "subject_1": "Cost-of-Living Adjustments for Service-Connected Benefits",
                    "document_numbers": ["2019-05287"]
                  },
                  {
                    "subject_1": "Meetings:",
                    "subject_2": "Veterans' Rural Health Advisory Committee",
                    "document_numbers": ["2019-05272"]
                  }
                ]
              }
            ]
          }
        ]
      }
    JSON
   }

  it "#documents_present_in_toc_but_not_in_xml" do
    date  = Date.new(2019,3,20)
    issue = Factory(:issue, publication_date: date)
    entry = Factory(:entry, document_number: '2019-05287', publication_date: date)
    allow_any_instance_of(ProblematicDocumentPresenter).to receive(:toc_json_file_contents).and_return(StringIO.new(toc_json).read)

    result = ProblematicDocumentPresenter.new(date).documents_present_in_toc_but_not_in_xml

    result.should == ["2019-05272"]
  end

  it "#documents_present_in_xml_but_not_in_toc" do
    date  = Date.new(2019,3,20)
    issue = Factory(:issue, publication_date: date)
    entry = Factory(:entry, document_number: '2019-05289', publication_date: date)
    allow_any_instance_of(ProblematicDocumentPresenter).to receive(:toc_json_file_contents).and_return(StringIO.new(toc_json).read)

    result = ProblematicDocumentPresenter.new(date).documents_present_in_xml_but_not_in_toc

    result.should == ['2019-05289']
  end

  context "#missing_executive_orders" do
    let!(:date) { Date.new(2022,12,30) }
    let!(:issue) { Factory(:issue, publication_date: date) }

    it "flags missing sequential EOs" do
      entry = Factory(:entry, publication_date: '2022-12-19', presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id, presidential_document_number: '14089')
      entry = Factory(:entry, publication_date: '2022-10-19', presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id, presidential_document_number: '14087')

      result = ProblematicDocumentPresenter.new(date).missing_executive_orders
      expect(result).to eq([14088])
    end

    it "returns empty array if EO is missing" do
      entry = Factory(:entry, publication_date: '2022-12-19', presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id, presidential_document_number: nil)
      result = ProblematicDocumentPresenter.new(date).missing_executive_orders
      expect(result).to eq([])
    end
  end

end
