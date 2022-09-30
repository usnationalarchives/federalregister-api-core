require "spec_helper"

describe EsPublicInspectionDocumentSearch, es: true do
  before(:each) do
    recreate_actual_pi_index_and_assign_alias!
  end

  def build_pi_doc_double(hsh)
    pi_doc = double('public_inspection_document')
    allow(pi_doc).to receive(:to_hash).and_return(hsh)
    allow(pi_doc).to receive(:id).and_return(hsh.fetch(:id))
    pi_doc
  end

  context "Elasticsearch query definition", pending: true do
    it "integrates a basic #with attribute" do
      search = described_class.new(conditions: {special_filing: 1})
      expect(search.send(:search_options)).to eq(
        {:from=>0,
          :size=>EsApplicationSearch::DEFAULT_RESULTS_PER_PAGE,
          :query=>
           {:function_score=>
             {:boost_mode=>"multiply",
              :functions=>
               [{:gauss=>
                  {:publication_date=>
                    {:decay=>"0.5", :offset=>"30d", :origin=>"now", :scale=>"365d"}}}],
              :query=>
               {:bool=>
                 {:filter=>[{:bool=>{:filter=>{:term=>{:special_filing=>true}}}}],
                  :must=>[]}}}},
          :sort=>[{:filed_at=>{:order=>"desc"}}, {:_score=>{:order=>"desc"}}],
          :_source => ['id']}
      )
    end

    it "builds the expected search with multiple attributes" do
      agency = Factory(:agency)
      search = described_class.new(conditions: {agencies: [agency.slug]})
      expect(search.send(:search_options)).to eq(
        {:from=>0,
          :size=>EsApplicationSearch::DEFAULT_RESULTS_PER_PAGE,
          :query=>
           {:function_score=>
             {:boost_mode=>"multiply",
              :functions=>
               [{:gauss=>
                  {:publication_date=>
                    {:decay=>"0.5", :offset=>"30d", :origin=>"now", :scale=>"365d"}}}],
              :query=>
               {:bool=>
                 {:filter=>[{:bool=>{:filter=>{:terms=>{:agency_ids=>[agency.id]}}}}],
                  :must=>[]}}}},
          :sort=>[{:filed_at=>{:order=>"desc"}}, {:_score=>{:order=>"desc"}}],
          :_source => ['id']}
      )
    end
  end

  context "ES Retrieval" do
    before(:each) do
      recreate_actual_pi_index_and_assign_alias!
    end

    context "Searching by term" do
      it "can search titles by term" do
        pi_doc = build_pi_doc_double(
          id: 1,
          title: "goats goats goats",
          full_text: "llamas"
        )
        save_documents_and_refresh_index(pi_doc)

        expect(described_class.new(conditions: { term: "goats" }).result_ids).to match_array [1]
        expect(described_class.new(conditions: { term: "boats" }).result_ids).to be_empty
      end

      it "can search full_text by term" do
        pi_doc = build_pi_doc_double(
          id: 1,
          title: "llamas",
          full_text: "goats"
        )
        save_documents_and_refresh_index(pi_doc)

        expect(described_class.new(conditions: { term: "goats" }).result_ids).to match_array [1]
        expect(described_class.new(conditions: { term: "boats" }).result_ids).to be_empty
      end

      context "Advanced Search" do
        context "Boolean Queries" do
          it "respects the AND operator (&)" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipes"),
              build_pi_doc_double(id: 2, full_text: "pipelines"),
              build_pi_doc_double(id: 3, full_text: "pipes pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "pipes" }).result_ids).to match_array [1,3]
            expect(described_class.new(conditions: { term: "pipelines" }).result_ids).to match_array [2,3]
            expect(described_class.new(conditions: { term: "pipes & pipelines" }).result_ids).to match_array [3]
          end

          it "respects the OR operator (|)" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipes"),
              build_pi_doc_double(id: 2, full_text: "pipelines"),
              build_pi_doc_double(id: 3, full_text: "pipes pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "pipes" }).result_ids).to match_array [1,3]
            expect(described_class.new(conditions: { term: "pipelines" }).result_ids).to match_array [2,3]
            expect(described_class.new(conditions: { term: "pipes | pipelines" }).result_ids).to match_array [1,2,3]
          end

          it "respects the NOT operator (-)" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipes"),
              build_pi_doc_double(id: 2, full_text: "pipelines"),
              build_pi_doc_double(id: 3, full_text: "pipes pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "-pipes" }).result_ids).to match_array [2]
            expect(described_class.new(conditions: { term: "-pipelines" }).result_ids).to match_array [1]
            expect(described_class.new(conditions: { term: "-pipe" }).result_ids).to match_array [1,2,3]
          end

          it "allows negative search on quoted phrases" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipes and"),
              build_pi_doc_double(id: 2, full_text: "pipes pipelines"),
              build_pi_doc_double(id: 3, full_text: "pipes and pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "-\"pipes and\"" }).result_ids).to match_array [2]
            expect(described_class.new(conditions: { term: "-\"and pipelines\"" }).result_ids).to match_array [1,2]
          end

          it "respects Groupings (())" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipes strength"),
              build_pi_doc_double(id: 2, full_text: "pipeline strength"),
              build_pi_doc_double(id: 3, full_text: "pipes pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "strength" }).result_ids).to match_array [1,2]
            expect(described_class.new(conditions: { term: "(pipes & strength) | (pipeline & strength)" }).result_ids).to match_array [1,2]
          end

          it "searches on an exact phrase (Phrase Search)" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipe strength"),
              build_pi_doc_double(id: 2, full_text: "pipeline strength"),
              build_pi_doc_double(id: 3, full_text: "pipe strength and pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "\"pipe strength\"" }).result_ids).to match_array [1,3]
            expect(described_class.new(conditions: { term: "\"pipeline strength\"" }).result_ids).to match_array [2]
          end

          it "searches on an exact form (Exact Form Search)" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "fisheries"),
              build_pi_doc_double(id: 2, full_text: "fishery"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "fishery" }).result_ids).to match_array [1,2]
            expect(described_class.new(conditions: { term: "=fishery" }).result_ids).to match_array [2]
          end

          it "searches on an exact phrase (Proximity Search)" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "rebuilt parts"),
              build_pi_doc_double(id: 2, full_text: "rebuilt vehicular parts"),
              build_pi_doc_double(id: 3, full_text: "rebuilt foreign boat parts"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "rebuilt parts" }).result_ids).to match_array [1,2,3]
            expect(described_class.new(conditions: { term: "\"rebuilt parts\"~2" }).result_ids).to match_array [1,2]
            expect(described_class.new(conditions: { term: "\"rebuilt parts\"~3" }).result_ids).to match_array [1,2,3]
          end

          it "handles escape sequences" do
            documents = [
              build_pi_doc_double(id: 1, full_text: "pipes strength"),
              build_pi_doc_double(id: 2, full_text: "pipeline strength"),
              build_pi_doc_double(id: 3, full_text: "pipes pipelines"),
            ]
            save_documents_and_refresh_index(documents)

            expect(described_class.new(conditions: { term: "\nstrength\r" }).result_ids).to match_array [1,2]
            expect(described_class.new(conditions: { term: "\"\"\"(pipes & strength) | (pipeline & strength)" }).result_ids).to match_array [1,2]
          end

        end
      end

      it "can search by agency slugs" do
        agency_a = FactoryGirl.create(:agency, name: "Fish Department", slug: "fish-department")
        doc_a = build_pi_doc_double(id: 1, full_text: "Fish", agency_ids: [agency_a.id])

        agency_b = FactoryGirl.create(:agency, name: "Transportation Department", slug: "transportation-department")
        doc_b = build_pi_doc_double(id: 2, full_text: "Trains", agency_ids: [agency_b.id])

        save_documents_and_refresh_index([doc_a, doc_b])

        expect(described_class.new(conditions: { agencies: ["fish-department"] }).result_ids).to match_array [1]
        expect(described_class.new(conditions: { agencies: ["transportation-department"] }).result_ids).to match_array [2]
        expect(described_class.new(conditions: { agencies: ["fish-department", "transportation-department"] }).result_ids).to match_array [1,2]
      end

      context "excerpts for multi-field mappings" do
        it "returns one excerpt for multiple hits on full_text" do
          document = FactoryGirl.create(
            :public_inspection_document,
           raw_text_updated_at: Time.current
          )
          allow(File).to receive(:file?).and_return(true)
          allow(File).to receive(:read).and_return("goats and llamas")
          save_documents_and_refresh_index(document)

          excerpt = described_class.new(
            excerpts: true,
            conditions: { term: "goats \"llamas\""
          }).results.first.excerpt
          expect(excerpt).to eq("<span class=\"match\">goats</span> and <span class=\"match\">llamas</span>")
        end

        it "returns one excerpt for multiple hits on title" do
          document = FactoryGirl.create(
            :public_inspection_document,
            raw_text_updated_at: Time.current
          )
          pi_doc = build_pi_doc_double(
            id: document.id,
            title: "goats and llamas",
            raw_text_updated_at: document.raw_text_updated_at.utc.iso8601
          )
          save_documents_and_refresh_index(pi_doc)

          excerpt = described_class.new(
            excerpts: true,
            conditions: { term: "goats \"llamas\""
          }).results.first.excerpt
          expect(excerpt).to eq("<span class=\"match\">goats</span> and <span class=\"match\">llamas</span>")
        end
      end

      describe ".result_ids" do
        it "returns result IDs from all returned pages of results" do
          documents = []
          (1..100).each do |i|
            documents << build_pi_doc_double({full_text: 'fried eggs', id: i})
          end
          save_documents_and_refresh_index(documents)

          search = described_class.new(conditions: {term: 'fried'}, per_page: 10)

          expect(search.results.es_ids).to match_array 1..10
          expect(search.result_ids).to match_array 1..100
        end
      end
    end

    context "ActiveRecord retrieval" do
      it "returns PublicInspectionDocument IDs associated with the search results" do
        documents = [
          FactoryGirl.create(:public_inspection_document),
          FactoryGirl.create(:public_inspection_document)
        ]
        save_documents_and_refresh_index(documents)

        search = described_class.new(per_page: 1, conditions: {})
        expect(search.valid?).to be true
        expect(search.results.ids).to eq documents.map(&:id)
      end

      context "pagination" do
        pending "respects a specified result size"
        pending "allows results from a certain page"

        it "can paginate through results" do
          documents = [
            FactoryGirl.create(:public_inspection_document),
            FactoryGirl.create(:public_inspection_document),
            FactoryGirl.create(:public_inspection_document),
            FactoryGirl.create(:public_inspection_document),
            FactoryGirl.create(:public_inspection_document)
          ]
          save_documents_and_refresh_index(documents)

          search = described_class.new(per_page: 2, conditions: {})
          expect(search.valid?).to be true
          expect(search.results.ids).to match_array documents.first(2).map(&:id)
          expect(search.results.total_pages).to eq 3
          expect(search.results.previous_page).to eq nil

          # Next page
          page_2_search = described_class.new(per_page: 2, page: search.results.next_page, conditions: {})
          expect(page_2_search.valid?).to be true
          expect(page_2_search.results.ids).to match_array documents[2..3].map(&:id)
          expect(page_2_search.results.total_pages).to eq 3
          expect(page_2_search.results.previous_page).to eq 1

          # Last page
          page_3_search = described_class.new(per_page: 2, page: page_2_search.results.next_page, conditions: {})
          expect(page_3_search.valid?).to be true
          expect(page_3_search.results.ids).to match_array [documents[4].id]
          expect(page_3_search.results.total_pages).to eq 3
          expect(page_3_search.results.previous_page).to eq 2
          expect(page_3_search.results.next_page).to eq nil
        end
      end

      pending "limits fields if specified"
      context "Agency associations" do
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
          save_documents_and_refresh_index([public_inspection_document_a, public_inspection_document_b])

          # Fab. PI docs
          search = described_class.new(
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

        it "applies a basic boolean filter correctly" do
          pending("This may need to be reimplemented")
          search = described_class.new(:conditions => {:special_filing => 1 })

          expect(search.results.count).to eq 1
        end
      end
    end
  end

  def save_documents_and_refresh_index(documents=[])
    Array(documents).each{|doc| $public_inspection_document_repository.save(doc)}
    $public_inspection_document_repository.refresh_index!
  end

end
