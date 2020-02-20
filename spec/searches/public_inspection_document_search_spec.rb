require "spec_helper"

describe "ES PI Doc Search" do

  before(:each) do
    $public_inspection_document_repository.create_index!(force: true)
  end

  context "Elasticsearch query definition" do
    it "integrates a basic #with attribute" do
      search = EsPublicInspectionDocumentSearch.new(conditions: {special_filing: 1})
      expect(search.send(:search_options)).to eq({
        query: {
          bool: {
            must: [],
            filter: [
              {
                bool: {
                  filter: {
                    term: {
                      special_filing: true
                    }
                  }
                }
              }
            ]
          }
        }
      })
    end

    it "builds the expected search with multiple attributes correctly" do
      agency = Factory(:agency)
      search = EsPublicInspectionDocumentSearch.new(conditions: {agencies: [agency.slug]})
      expect(search.send(:search_options)).to eq({
        query: {
          bool: {
            must: [],
            filter: [
              {
                bool: {
                  filter: {
                    terms: {
                      agency_ids: [agency.id]
                    }
                  }
                }
              }
            ]
          }
        }
      })
    end
  end

  context "search results" do
    let!(:agency_a) { Factory(:agency) }
    let!(:agency_b) { Factory(:agency) }

    let!(:public_inspection_document_a) do
      Factory(:public_inspection_document,
        id: 99,
        special_filing: 1,
        publication_date: Date.new(2020,1,1),
        subject_1: 'fish',
        subject_2: 'fish',
        subject_3: 'fish',
        document_number: 'abc-1'
      ).tap do |doc|
        #expect(doc).to receive(:document_file_path).and_return(nil)
        AgencyAssignment.create(assignable: doc, agency: agency_a)

        # create docket numbers
        doc.docket_numbers.create(number: 1)
        doc.docket_numbers.create(number: 2)
      end
    end

    let!(:public_inspection_document_b) do
      Factory(:public_inspection_document,
        special_filing: 0,
        publication_date: Date.new(2020,1,2),
        subject_1: 'goats',
        subject_2: 'goats',
        subject_3: 'goats',
        document_number: 'abc-2'
      ).tap do |doc|
        AgencyAssignment.create(assignable: doc, agency: agency_b)

      end
    end

    it 'returns appropriately filtered search results' do
      $public_inspection_document_repository.save(public_inspection_document_a)
      $public_inspection_document_repository.save(public_inspection_document_b)
      $public_inspection_document_repository.refresh_index!

      # Fab. PI docs
      search = EsPublicInspectionDocumentSearch.new(
        conditions: {
          term: 'fish',
          special_filing: 1,
          agencies: [agency_a.slug],
          # publication_date: Date.new(2020,1,1), Not a valid field
          # title: "fish fish fish",
          # full_text: TBD
          # document_numbers: [public_inspection_document_a.document_number],
          docket_id: 1,
          agency_ids: [agency_a.id]
        }
      )
      expect(search.validation_errors).to be_empty
      expect(search.valid?).to eq true

      expect(search.results.count).to eq 1
    end
  end

  it "applies a basic boolean filter correctly" do
    search = EsPublicInspectionDocumentSearch.new(:conditions => {:special_filing => 1 })

    expect(search.results.count).to eq 1
  end

end
