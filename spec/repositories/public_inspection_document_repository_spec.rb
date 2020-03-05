require 'spec_helper'

describe PublicInspectionDocumentRepository do
  let(:agency) { Factory(:agency) }
  before(:all) do
    $public_inspection_document_repository.create_index!(force: true)
  end

  describe "#mappings" do
    it "creates an index with the appropriate mappings" do
      expected_mappings = {
        dynamic: "strict",
        properties: {
          id: {
            type: 'integer'
          },
          agency_ids: {
            type: 'integer'
          },
          docket_id: {
            type: 'keyword'
          },
          docket_numbers: {
            type: 'object'
          },
          document_number: {
            type: 'keyword'
          },
          filed_at: {
            type: 'date'
          },
          full_text: {
            type: 'text', index_options: 'offsets'
          },
          public_inspection_document_id: {
            type: 'integer'
          },
          public_inspection_issues: {
            type: 'object'
          },
          publication_date: {
            type: 'date'
          },
          special_filing: {
            type: 'boolean'
          },
          title: {
            type: 'text', index_options: 'offsets'
          },
          type: {
            type: 'keyword'
          }
        }
      }

      expect($public_inspection_document_repository.mappings.to_hash).to eq expected_mappings
    end
  end

  describe "#search" do
    let(:public_inspection_document) do
      Factory(:public_inspection_document, publication_date: Date.new(2020,1,1)).tap do |document|
        # set up associations in factories
        document.agency_assignments.create(agency: agency)
      end
    end

    it "retrieves indexed public inspection documents" do
      $public_inspection_document_repository.save(public_inspection_document)
      $public_inspection_document_repository.refresh_index!

      search = $public_inspection_document_repository.search("2020-01-01")
      result = search.results.first
      expect(result.agency_ids).to eq [agency.id]
      expect(result.publication_date).to eq Date.new(2020,1,1)
    end
  end

  describe "#update" do
  end

  describe "#delete" do
  end
end
