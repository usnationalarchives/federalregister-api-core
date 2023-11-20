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

  it "flags documents that reference 'courts' in the dates section." do
    date  = Date.new(2023,7,21)
    issue = Factory(:issue, publication_date: date)
    entry = Factory(
      :entry,
      publication_date: date,
      granule_class: 'RULE'
    )
    Event.create!(
      date: '2017-01-01', #eg effective date is after publication date
      entry_id: entry.id,
      event_type: 'EffectiveDate'
    )
    allow_any_instance_of(ProblematicDocumentPresenter).to receive(:extract_dates).and_return([
      'This rule is effective on January 1, 2017, because the District Court vacated certain provisions of the rule that became effective on that date (81 FR 43338).',
      ["January 1, 2017"]
    ])
    result = ProblematicDocumentPresenter.new(date).documents_referencing_courts

    expect(result).to eq({
      entry => "This rule is effective on <span style='color: red; font-weight: bold'>January 1, 2017</span>, because the District Court vacated certain provisions of the rule that became effective on that date (81 FR 43338)."
    })
  end

  it "flags possibly incorrect effective dates" do
    date  = Date.new(2023,11,20)
    issue = Factory(:issue, publication_date: date)
    entry = Factory(:entry,
      publication_date: date,
      granule_class: 'RULE'
    )
    pi_doc = Factory(:public_inspection_document,
      filed_at: Date.new(2023,8,11),
      entry_id: entry.id
    )
    Event.create!(
      date: '2023-08-10', #eg effective date is before PIL publication date
      entry_id: entry.id,
      event_type: 'EffectiveDate'
    )
    allow_any_instance_of(ProblematicDocumentPresenter).to receive(:extract_dates).and_return([
      'This final rule is effective on December 18, 2023',
      ["December 18, 2023"]
    ])
    result = ProblematicDocumentPresenter.new(date).possibly_errant_documents_with_effective_dates

    expect(result).to eq({
      entry => "This final rule is effective on <span style='font-weight: bold;'>December 18, 2023</span>"
    })
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
