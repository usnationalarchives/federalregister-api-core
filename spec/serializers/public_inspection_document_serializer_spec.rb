require "spec_helper"

describe PublicInspectionDocumentSerializer do
  it ".find_options_for returns options via " do
    result = described_class.find_options_for([:agencies])
    expect(result).to eq({:select=>"id, raw_text_updated_at", :include=>[{:agency_names=>:agency}]})
  end

  context "Active record objects are serialized differently than ES objects" do
    it "includes page views" do
      pi_doc = Factory(:public_inspection_document, filed_at: Date.current)
      result = described_class.new(pi_doc, params: {active_record_retrieval: true}).to_h.fetch(:page_views)
      expect(result).to eq(:count=>0, :last_updated=>nil)
    end

    it "includes non-capitalized types" do
      pi_doc = Factory(:public_inspection_document, granule_class: 'RULE')
      result = described_class.new(pi_doc, params: {active_record_retrieval: true}).to_h.fetch(:type)
      expect(result).to eq("Rule")
    end

  end

  it ".find_options_for matches the interface of the historical API representation" do
    fields = PublicInspectionDocumentSerializer.default_show_fields_json
    find_options_from_public_inspection_document_api_representation = {
      :select=>"id, raw_text_updated_at, publication_date, document_number, editorial_note, filed_at, special_filing, subject_1, subject_2, subject_3, num_pages, pdf_file_name, pdf_file_size, pdf_updated_at, granule_class",
      :include=>[{:agency_names=>:agency}, :pil_agency_letters, :docket_numbers, :public_inspection_issues]
    }
    find_options_per_serializer = PublicInspectionDocumentSerializer.find_options_for(fields + [:document_number])

    expect(find_options_per_serializer).to eq(find_options_from_public_inspection_document_api_representation)
  end

end
