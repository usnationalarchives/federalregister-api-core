require 'spec_helper'

describe EntryRegulationsDotGovImporter do
  it "assigns regs.gov metadata attributes in the historical fashion" do
    entry = Factory(:entry, document_number: '2022-28376')
    VCR.use_cassette("entry_regulations_dot_gov_importer_multi_document") do
      allow_any_instance_of(RegulationsDotGov::V4::Client).to receive(:api_key).and_return("DEMO_KEY")
      EntryRegulationsDotGovImporter.new.perform(entry.document_number)
    end

    expect(entry.reload).to have_attributes(
      comment_count:                         3,
      comment_url:                           "http://www.regulations.gov/commenton/HHS_FRDOC_0001-0882",
      regulations_dot_gov_comments_close_on: Date.new(2023,3,15),
      regulations_dot_gov_docket_id:         "HHS_FRDOC_0001",
      regulations_dot_gov_document_id:       "HHS_FRDOC_0001-0882",
    )
  end

  it "creates regulations dot gov documents and dockets if they do not exist" do
    entry = Factory(:entry, document_number: '2022-28376')
    RegsDotGovDocket.create!(id: "HHS_FRDOC_0001")
    VCR.use_cassette("entry_regulations_dot_gov_importer_multi_document") do
      expect(DocketImporter).to receive(:new).exactly(8).times.and_return(double(perform: 'arbitrary')) # ie if a docket is a new record, always resync inline
      allow_any_instance_of(RegulationsDotGov::V4::Client).to receive(:api_key).and_return("DEMO_KEY")
      EntryRegulationsDotGovImporter.new.perform(entry.document_number)
    end

    expect(RegsDotGovDocument.count).to eq(9)
    expect(RegsDotGovDocket.count).to eq(9)
    sample_document = RegsDotGovDocument.find_by_regulations_dot_gov_document_id!("HHS_FRDOC_0001-0882")
    expect(sample_document).to have_attributes(
      allow_late_comments:                       nil,
      comment_count:                             3,
      comment_end_date:                          Date.new(2023,3,15),
      comment_start_date:                        Date.new(2023,1,13),
      deleted_at:                                nil,
      docket_id:                                 "HHS_FRDOC_0001",
      federal_register_document_number:          entry.document_number,
      original_federal_register_document_number: entry.document_number,
      regulations_dot_gov_document_id:           "HHS_FRDOC_0001-0882",
      regulations_dot_gov_object_id:             "09000064855eb9c5"
    )
  end

  it "handles a federal register document number change where the regs.gov document id remains the same" do
    entry = Factory(:entry, document_number: '2022-24705')
    regs_dot_gov_document = Factory(
      :regs_dot_gov_document,
      federal_register_document_number:          entry.document_number,
      original_federal_register_document_number: entry.document_number,
      regulations_dot_gov_document_id:           "HHS_FRDOC_0001-0882",
    )

    api_result = RegulationsDotGov::V4::BasicDocument.new({
      'id'       => "HHS_FRDOC_0001-0882",
      'attributes' => {
        'frDocNum' => 'NEW_FR_DOC_NUMBER'
      }
    })
    allow_any_instance_of(EntryRegulationsDotGovImporter).to receive(:regulations_dot_gov_documents).and_return([api_result])
    allow_any_instance_of(RegulationsDotGov::V4::BasicDocument).to receive(:comment_count).and_return(99999999)

    EntryRegulationsDotGovImporter.new.perform(entry.document_number)

    expect(regs_dot_gov_document.reload).to have_attributes(
      deleted_at:                                nil,
      federal_register_document_number:          'NEW_FR_DOC_NUMBER',
      original_federal_register_document_number: '2022-24705',
    )
  end

  it "properly processess api response in which regulations.gov document ids change but the regulations_dot_gov_object_id remains the same" do
    entry = Factory(:entry, document_number: '2022-28376')

    regs_dot_gov_document = Factory(:regs_dot_gov_document,
      docket_id: "ARBITRARY_INITIAL_DOCKET_NUMBER",
      federal_register_document_number: entry.document_number,
      original_federal_register_document_number: entry.document_number,
      regulations_dot_gov_document_id: "ARBITRARY_INITIAL_DOCKET_NUMBER-1234"
    )

    VCR.use_cassette("entry_regulations_dot_gov_importer_multi_document") do
      allow_any_instance_of(RegulationsDotGov::V4::Client).to receive(:api_key).and_return("DEMO_KEY")
      EntryRegulationsDotGovImporter.new.perform(entry.document_number)
    end

    result = RegsDotGovDocument.unscoped.where(
      regulations_dot_gov_object_id: regs_dot_gov_document.regulations_dot_gov_object_id
    ).count
    # no new new record created
    expect(result).to eq(1)
    expect(regs_dot_gov_document.reload.deleted_at).to be_truthy

    # dockets correctly created
    expect(RegsDotGovDocket.count).to eq(9)
  end

end
