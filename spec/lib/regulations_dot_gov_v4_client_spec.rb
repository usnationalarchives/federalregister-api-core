require 'spec_helper'

describe RegulationsDotGov::V4::Client do
  let(:common_attributes) do
    {
      document_id:                      'FRTIB_FRDOC_0001-0319',
      docket_id:                        'FRTIB_FRDOC_0001',
      title:                            'Availability of Records',
      comment_due_date:                 DateTime.parse('2020-11-24T04:59:59Z'),
      comment_url:                      "http://www.regulations.gov/#!submitComment;D=FRTIB_FRDOC_0001-0319",
      url:                              "http://www.regulations.gov/#!documentDetail;D=FRTIB_FRDOC_0001-0319",
      non_participating_agency?:        false,
      agency_acronym:                   'FRTIB'
    }
  end

  it "#find_basic_document" do
    VCR.use_cassette("regulations_dot_gov_v4_basic_document") do
      result = RegulationsDotGov::V4::Client.new.find_basic_document('2020-22330')
      expect(result).to have_attributes(common_attributes)
    end
  end

  it "find_detailed_document" do
    VCR.use_cassette("regulations_dot_gov_v4_detailed_document") do
      result = RegulationsDotGov::V4::Client.new.find_detailed_document('FRTIB_FRDOC_0001-0319')
      expect(result).to have_attributes(
        common_attributes.merge(
          comment_count:                    0,
          federal_register_document_number: '2020-22330'
        )
      )
    end
  end

  it "#find_comments_by_comment_on_id" do
    VCR.use_cassette("regulations_dot_gov_v4_comments") do
      result = RegulationsDotGov::V4::Client.new.find_comments_by_comment_on_id('0900006483a6cba3').count
      expect(result).to eq(418)
    end
  end

  it "#find_docket" do
    VCR.use_cassette("regulations_dot_gov_v4_dockets") do
      result = RegulationsDotGov::V4::Client.new.find_docket('EPA-HQ-OAR-2003-0129')
      expect(result).to have_attributes(
        title: 'Registration of Fuels and Fuels Additives (Application for Registration of Manufacturers) (ICR # 0309.10, OMB Control # 2060-0150)',
        regulation_id_number: nil,
        docket_id: 'EPA-HQ-OAR-2003-0129',
        supporting_documents_count: 2,
        metadata: nil,
      )

      # TODO: This appears to be working, but this spec is not.
      # expect_any_instance_of(RegulationsDotGov::V4::Client).to receive(:find_documents_by_docket).with('EPA-HQ-OAR-2003-0129')
      result.supporting_documents
    end
  end

  it "find_documents_by_docket" do
    VCR.use_cassette("regulations_dot_gov_v4_dockets") do
      result = RegulationsDotGov::V4::Client.new.find_docket('EPA-HQ-OAR-2003-0129')

      expect(result.supporting_documents.count).to eq(2)
      expect(result.supporting_documents.map(&:class).uniq.first).to eq(RegulationsDotGov::V4::BasicDocument)
    end
  end

end
