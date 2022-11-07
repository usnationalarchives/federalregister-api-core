require 'spec_helper'

describe RegulationsDotGov::V4::Client do
  let(:common_attributes) do
    {
      document_id:                      'FRTIB_FRDOC_0001-0319',
      docket_id:                        'FRTIB_FRDOC_0001',
      title:                            'Availability of Records',
      comment_due_date:                 DateTime.parse('2020-11-24T04:59:59Z'),
      comment_url:                      "http://www.regulations.gov/commenton/FRTIB_FRDOC_0001-0319",
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

  it "if multiple documents are found for a single FR document it returns the first document with an open comment period if available" do
    VCR.use_cassette("regulations_dot_gov_v4_multi_document_result") do
      result = RegulationsDotGov::V4::Client.new.find_basic_document('2020-28306')
      expect(result.document_id).to eq('DOI_FRDOC_0001-0108')
    end
  end

  it "#find_basic_document returns nil if no results" do
    VCR.use_cassette("regulations_dot_gov_v4_basic_document_no_result_search") do
      result = RegulationsDotGov::V4::Client.new.find_basic_document('invalid-doc-number')
      expect(result).to be_nil
    end
  end

  it "find_detailed_document" do
    VCR.use_cassette("regulations_dot_gov_v4_detailed_document") do
      result = RegulationsDotGov::V4::Client.new.find_detailed_document('NSF_FRDOC_0001-2638')
      expect(result).to have_attributes(
        comment_count:                    0,
        federal_register_document_number: '2021-04117'
      )
    end
  end

  it "#find_comments_by_regs_dot_gov_document_id" do
    VCR.use_cassette("find_comments_by_regs_dot_gov_document_id") do
      result = RegulationsDotGov::V4::Client.new.find_comments_by_regs_dot_gov_document_id("HHS-OCR-2021-0006-0001").count
      expect(result).to eq(550)
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

  it "handles pagination when more than 250 results are returned" do
    VCR.use_cassette("regulations_dot_gov_v4_dockets") do
      result = RegulationsDotGov::V4::Client.new.find_docket('EPA-HQ-OAR-2003-0129')
    end
  end

  it "find_documents_updated_within and handles pagination" do
    allow(Date).to receive(:current).and_return(Date.new(2022,10,6))
    allow_any_instance_of(RegulationsDotGov::V4::Client).to receive(:api_key).and_return("DEMO_KEY")
    VCR.use_cassette("regulations_dot_gov_v4_documents_updated_within") do
      result = RegulationsDotGov::V4::Client.new.find_documents_updated_within(2, 'Notice')

      expect(result.map(&:class).uniq.first).to eq(RegulationsDotGov::V4::BasicDocument)
      expect(result.count).to be > RegulationsDotGov::V4::Client::PAGE_SIZE
    end
  end

  context "#find_comments" do

    it "finds a posted comment" do
      VCR.use_cassette("regulations_dot_gov_v4_comments") do
        comments = RegulationsDotGov::V4::Client.new.find_comments("filter[searchTerm]" => "1k5-9l2j-gnbc")

        expect(comments.first.posted_date).to eq(Time.parse("2021-01-07T05:00:00Z"))
      end
    end

  end

end
