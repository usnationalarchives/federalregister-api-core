require 'spec_helper'

describe PublicInspectionDocumentRepository do
  let(:agency) { Factory(:agency) }
  let(:public_inspection_document_repository) { $public_inspection_document_repository }

  describe "#mappings" do
    it "creates an index with the appropriate mappings" do
      expected_mappings = {
        dynamic: "strict",
        properties: {
          agency_ids: {
            type: 'integer'
          },
          publication_date: {
            type: 'date'
          }
        }
      }

      expect($public_inspection_document_repository.mappings.to_hash).to eq expected_mappings
    end
  end

  describe "#save" do
    let(:public_inspection_document) do
      Factory(:public_inspection_document, publication_date: Date.current).tap do |document|
        # set up associations in factories
        document.agency_assignments.create(agency: agency)
      end
    end

    it "indexes a PublicInspectionDocument" do
      serialized_document = PublicInspectionDocumentSerializer.new(public_inspection_document)
      public_inspection_document_repository.save(serialized_document)
      public_inspection_document_repository.refresh_index!

      search = public_inspection_document_repository.search("2020-02-10")
      result = search.results.first
      expect(result.agency_ids).to eq [agency.id]
      expect(result.publication_date).to eq Date.new(2020,2,10)
    end
  end
end
