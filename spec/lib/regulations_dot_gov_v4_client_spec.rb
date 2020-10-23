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

  it "#find_basic_document_by_document_number", vcr: false do
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


end
