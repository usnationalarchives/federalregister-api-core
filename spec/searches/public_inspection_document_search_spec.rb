require "spec_helper"

describe "ES PI Doc Search" do
  before(:each) do
    allow(ElasticsearchIndexer).to receive(:es_enabled?).and_return(true)
    $public_inspection_document_repository.create_index!(force: true)
  end

  context "Elasticsearch query definition" do
    it "integrates a basic #with attribute" do
      pending("Fix this spec once the query API has sufficiently hardened")
      search = EsPublicInspectionDocumentSearch.new(conditions: {special_filing: 1})
      expect(search.send(:search_options)).to eq({
        from: 0,
        size: 20,
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
        },
        sort: [{filed_at: {order: 'desc'}}],
      })
    end

    it "builds the expected search with multiple attributes" do
      pending("Fix this spec once the query API has sufficiently hardened")
      agency = Factory(:agency)
      search = EsPublicInspectionDocumentSearch.new(conditions: {agencies: [agency.slug]})
      expect(search.send(:search_options)).to eq({
        from: 0,
        size: 20,
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
        },
        sort: [{filed_at: {order: 'desc'}}],
      })
    end
  end

  context "searching on attributes" do
    before(:each) do
      allow(File).to receive(:read).and_return("Fish and goats")
    end

    it "can search titles by term" do
      $public_inspection_document_repository.save(
        FactoryGirl.build(:public_inspection_document,
          id: 1,
          subject_1: 'goats',
          subject_2: 'goats',
          subject_3: 'goats'
        ),
        refresh: true
      )

      expect(EsPublicInspectionDocumentSearch.new(conditions: { term: 'goats' }).results.count).to eq 1
      expect(EsPublicInspectionDocumentSearch.new(conditions: { term: 'boats' }).results.count).to eq 0
    end

    it "can search full_text by term" do
      allow_any_instance_of(PublicInspectionDocumentSerializer).to receive(:full_text).and_return("Fish and goats")

      $public_inspection_document_repository.save(
        FactoryGirl.build(:public_inspection_document,
          id: 1,
          subject_1: 'goats',
          subject_2: 'goats',
          subject_3: 'goats'
        ),
        refresh: true
      )

      expect(EsPublicInspectionDocumentSearch.new(conditions: { term: 'goats' }).results.count).to eq 1
      expect(EsPublicInspectionDocumentSearch.new(conditions: { term: 'boats' }).results.count).to eq 0
    end

    pending "can search agency_name by term" do
      # Not sure this is fully supported at the moment
      # check the index- old index
      # expect(File).to receive(:read).and_return(nil)
      # allow_any_instance_of(PublicInspectionDocument).to receive(:document_file_path).and_return(nil)

      agency = FactoryGirl.create(:agency, name: "AgencyA")
      doc = FactoryGirl.create(:public_inspection_document,
        id: 1,
      )
      AgencyAssignment.create(assignable: doc, agency: agency)
      $public_inspection_document_repository.save(
        doc,
        refresh: true
      )

      expect(EsPublicInspectionDocumentSearch.new(conditions: { term: 'AgencyA' }).results.count).to eq 1
      expect(EsPublicInspectionDocumentSearch.new(conditions: { term: 'AgencyB' }).results.count).to eq 0
    end

    it "filters results by type" do
      $public_inspection_document_repository.save(
        FactoryGirl.create(:public_inspection_document,
          id: 1,
          granule_class: "SUNSHINE"
        ),
        refresh: true
      )

      search_with_hit = EsPublicInspectionDocumentSearch.new(conditions: { type: 'NOTICE' })
      expect(search_with_hit.valid?).to be true
      expect(search_with_hit.results.count).to eq 1

      search_without_hit = EsPublicInspectionDocumentSearch.new(conditions: { type: 'RULE' })
      expect(search_without_hit.valid?).to be true
      expect(search_without_hit.results.count).to eq 0
    end
  end

  context "active record and pagination" do
    before(:each) do
      allow(File).to receive(:read).and_return("Fish and goats")
    end

    pending "respects a specified result size"
    pending "allows results from a certain page"

    it "returns PublicInspectionDocument IDs associated with the search results" do
      documents = [
        FactoryGirl.create(:public_inspection_document),
        FactoryGirl.create(:public_inspection_document)
      ].tap do |docs|
        docs.each do |doc|
          $public_inspection_document_repository.save(doc)
        end
      end
      $public_inspection_document_repository.refresh_index!

      search = EsPublicInspectionDocumentSearch.new(per_page: 1, conditions: {})
      expect(search.valid?).to be true
      expect(search.results.ids).to eq documents.map(&:id)
    end

    it "can paginate through results" do
      documents = [
        FactoryGirl.create(:public_inspection_document),
        FactoryGirl.create(:public_inspection_document),
        FactoryGirl.create(:public_inspection_document),
        FactoryGirl.create(:public_inspection_document),
        FactoryGirl.create(:public_inspection_document)
      ].tap do |docs|
        docs.each do |doc|
          $public_inspection_document_repository.save(doc)
        end
      end
      $public_inspection_document_repository.refresh_index!

      search = EsPublicInspectionDocumentSearch.new(per_page: 2, conditions: {})
      expect(search.valid?).to be true
      expect(search.results.ids).to match_array documents.first(2).map(&:id)
      expect(search.results.total_pages).to eq 3
      expect(search.results.previous_page).to eq nil

      # Next page
      page_2_search = EsPublicInspectionDocumentSearch.new(per_page: 2, page: search.results.next_page, conditions: {})
      expect(page_2_search.valid?).to be true
      expect(page_2_search.results.ids).to match_array documents[2..3].map(&:id)
      expect(page_2_search.results.total_pages).to eq 3
      expect(page_2_search.results.previous_page).to eq 1

      # Last page
      page_3_search = EsPublicInspectionDocumentSearch.new(per_page: 2, page: page_2_search.results.next_page, conditions: {})
      expect(page_3_search.valid?).to be true
      expect(page_3_search.results.ids).to match_array [documents[4].id]
      expect(page_3_search.results.total_pages).to eq 3
      expect(page_3_search.results.previous_page).to eq 2
      expect(page_3_search.results.next_page).to eq nil
    end
  end

  context "Elasticsearch retrieval" do
    before(:each) do
      $public_inspection_document_repository.create_index!(force: true)
    end

    pending "limits fields if specified"

    let!(:agency_a) { Factory(:agency) }
    let!(:agency_b) { Factory(:agency) }

    let!(:public_inspection_document_a) do
      Factory(:public_inspection_document,
        id: 99,
        # full_text:
        # docket_id:
        # document_number:
        # public_inspection_document_id
        # type:
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
          # available_on:
          # page:
          # per_page
          # type:
          docket_id: 1,
          # special_filing:
          # publication_date: Date.new(2020,1,1), Not a valid field
          # title: "fish fish fish",
          # full_text: TBD
          # document_numbers: [public_inspection_document_a.document_number],
          #agency_ids: [agency_a.id]
        }
      )
      expect(search.validation_errors).to be_empty
      expect(search.valid?).to eq true

      expect(search.results.count).to eq 1
    end
  end

  it "applies a basic boolean filter correctly" do
    pending("This may need to be reimplemented")
    search = EsPublicInspectionDocumentSearch.new(:conditions => {:special_filing => 1 })

    expect(search.results.count).to eq 1
  end
end
