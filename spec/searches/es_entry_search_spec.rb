require "spec_helper"

describe EsEntrySearch, es: true do
  before(:context) do
    OpenSearchIngestPipelineRegistrar.create_chunking_ingest_pipeline!(OpenSearchMlModelRegistrar.model_id)
  end

  def build_entry_double(hsh)
    if hsh[:document_number].blank?
      hsh.merge!(document_number: "2099-#{rand(5000)}")
    end
    entry = double('entry')
    allow(entry).to receive(:to_hash).and_return(hsh)
    allow(entry).to receive(:id).and_return(hsh.fetch(:id))
    entry
  end

  def assert_valid_search(search)
    expect(search.valid?).to eq(true)
  end

  let!(:entry) do
    Factory(
      :entry,
      publication_date: Date.new(2020,1,1),
      significant: 1,
    )
  end

  context "Pre-ES specs" do
    #NOTE: These specs were used for testing search before the ES upgrade.

    describe 'agency_ids' do
      it "populates es `with`" do
        agencies = (1..2).map{ Factory.create(:agency) }
        search = described_class.new()
        search.agency_ids = agencies.map(&:id)
        search.with.should == {:agency_ids => agencies.map(&:id)}
      end
    end

    describe 'significant' do
      it "populates sphinx `with`" do
        search = described_class.new()
        search.significant = 1
        search.with.should == {:significant => true}
      end
    end

    describe 'type' do
      it "populates sphinx `with`, CRC32 escaping" do
        search = described_class.new
        search.type = ['RULE', 'PRORULE']
        search.with.should == {:type => ['RULE', 'PRORULE']}
      end

      it "collapses sunlight and notices"
    end

    describe 'presidential_document_type' do
      it "populates sphinx `with`" do
        search = described_class.new
        search.presidential_document_type = ["determination", "executive_order"]
        search.with.should == {:presidential_document_type_id => [1,2]}
      end
    end

    describe 'cfr' do
      it "populates sphinx `with` using the custom citation format" do
        pending("May not be needed")
        search = described_class.new
        search.cfr = {:title => '10', :part => '101'}
        search.with.should == {:cfr_affected_parts => 1000101}
      end
    end

    describe 'regulation_id_number' do
      it "populates sphinx `conditions` and properly quotes" do
        pending("May not be needed")
        search = described_class.new()
        search.regulation_id_number = "ABCD-1234"
        search.es_conditions.should == {:regulation_id_number => '"=ABCD =1234"'}
      end
    end

    describe 'matching_entry_citation' do
      before(:each) do
        allow(Issue).to receive(:current).and_return(Issue.new(:publication_date => Date.today))
      end

      it "finds no match when no term" do
        described_class.new().matching_entry_citation.should be_nil
      end

      it "finds no match for terms that aren't FR citations" do
        described_class.new(:conditions => {:term => "ABCD"}).matching_entry_citation.should be_nil
        described_class.new(:conditions => {:term => "10 CFR 120"}).matching_entry_citation.should be_nil
      end

      it "finds no match for terms that contain more than an FR citation" do
        described_class.new(:conditions => {:term => "before 71 FR 12345"}).matching_entry_citation.should be_nil
        described_class.new(:conditions => {:term => "71 FR 12345 after"}).matching_entry_citation.should be_nil
        described_class.new(:conditions => {:term => "before 71 FR 12345 after"}).matching_entry_citation.should be_nil
      end

      it "finds a match for valid 'OFR-style' FR citations" do
        citation_attributes = Citation.new(:citation_type => "FR", :part_1 => 71, :part_2 => 12345).attributes
        described_class.new(:conditions => {:term => "71 FR 12345"}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => "71FR12345"}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => " 71 FR 12345 "}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => "71 F.R. 12345"}).matching_entry_citation.attributes.should == citation_attributes
      end

      it "find a match for valid 'Harvard-style' FR citations" do
        citation_attributes = Citation.new(:citation_type => "FR", :part_1 => 71, :part_2 => 12345).attributes
        described_class.new(:conditions => {:term => "71 Fed Reg 12345"}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => "71 Fed. Reg. 12345"}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => "71 Fed. Reg. 12,345"}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => " 71 fed reg 12345 "}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => "71 fedreg 12345"}).matching_entry_citation.attributes.should == citation_attributes
        described_class.new(:conditions => {:term => "71fedreg12345"}).matching_entry_citation.attributes.should == citation_attributes
      end
    end

    describe 'publication_date' do
      [:is, :gte, :lte].each do |type|
        describe "`#{type}`" do
          describe 'error handling' do
            before(:each) do
              @date_string = "NOT A VALID DATE"
              @search = described_class.new(:conditions => {:publication_date => {type => @date_string}})
            end

            it "adds an error when given a bad `#{type}` date" do
              @search.validation_errors[:publication_date].should be_present
            end

            it "populates the value when given a bad `#{type}` date" do
              @search.publication_date.send(type).should == @date_string
            end
          end
        end
      end
    end

    describe 'entry_with_document_number' do
      before(:each) do
        allow(Issue).to receive(:current).and_return(Issue.new(:publication_date => Date.today))
      end

      it "finds no match when no term" do
        described_class.new().entry_with_document_number.should be_nil
      end

      it "finds no match for terms that aren't FR citations" do
        described_class.new(:conditions => {:term => "ABCD"}).entry_with_document_number.should be_nil
      end

      it "finds a match for valid FR document numbers" do
        entry = Entry.create!(:document_number => "2010-1")
        described_class.new(:conditions => {:term => "2010-1"}).entry_with_document_number.should == entry
      end
    end

    describe 'results_for_date' do
      it "retains the same filters/conditions, but forces a particular publication_date" do
        pending("Readdress when re-recording TS v3 VCR specs")
        date = Date.parse("2010-10-10")
        search = described_class.new(:conditions => {:term => "HOWDY", :significant => '1', :cfr =>{:title => '7', :part => '132'}})

        Entry.should_receive(:search).with(
          'HOWDY',
          hash_including(
            with: hash_including(
              significant: '1',
              publication_date: (date.to_time.utc.beginning_of_day.to_i .. date.to_time.utc.end_of_day.to_i)
            ),
            per_page: 1000
          )
        )
        search.results_for_date(date)
      end
    end

    describe "summary" do
      it "says 'All Documents' if no term or filters" do
        described_class.new(:conditions => {}).summary.should == "All Documents"
      end

      it "includes the term" do
        described_class.new(:conditions => {:term => "OH HAI"}).summary.should == "Documents matching 'OH HAI'"
      end

      it "includes the effective date" do
        search = described_class.new(:conditions => {:effective_date => {:year => 2011}})

        search.summary.should == "Documents with an effective date in 2011"
      end

      it "includes the single agency" do
        agency = Factory(:agency, :name => "Commerce Department")
        search = described_class.new(:conditions => {:agency_ids => [agency.id]})

        search.summary.should == "Documents from Commerce Department"
      end

      it "includes all agencies" do
        agency_1 = Factory(:agency, :name => "Commerce Department")
        agency_2 = Factory(:agency, :name => "State Department")
        search = described_class.new(:conditions => {:agency_ids => [agency_1.id,agency_2.id]})

        search.summary.should == "Documents from Commerce Department or State Department"
      end

      it "includes the document type" do
        search = described_class.new(:conditions => {:type => ['RULE','PRORULE']})
        search.summary.should == "Documents of type Rule or Proposed Rule"
      end

      it "includes the agency docket" do
        search = described_class.new(:conditions => {:docket_id => 'EPA-HQ-OPPT-2005-0049'})
        search.summary.should == "Documents filed under agency docket EPA-HQ-OPPT-2005-0049"
      end

      it "includes the significance" do
        search = described_class.new(:conditions => {:significant => '1'})
        search.summary.should == "Documents whose Associated Unified Agenda Deemed Significant Under EO 12866"
      end

      it "includes the affected CFR part" do
        search = described_class.new(:conditions => {:cfr => {:title => '40', :part => '745'}})
        search.summary.should == "Documents affecting 40 CFR 745"
      end

      #TODO: uncomment when merging new geolocation code
      it "includes the location"# do
      #   search = described_class.new(:conditions => {:near => {:location => " 94118", :within => 50}})
      #   search.summary.should == "Documents located within 50 miles of  94118"
      # end

      it "includes the section" do
        section = Factory(:section, :title => "Environment")
        search = described_class.new(:conditions => {:section_ids => [section.id]})
        search.summary.should == "Documents in Environment"
      end

      it "includes the topic" do
        topic = Factory(:topic, :name => "Reporting and recordkeeping requirements")
        search = described_class.new(:conditions => {:topic_ids => [topic.id]})
        search.summary.should == "Documents about Reporting and recordkeeping requirements"
      end

      it "combines multiple types of filters with the appropriate conjunction" do
        search = described_class.new(:conditions => {
              :term => "fishing",
              :type => ['RULE','PRORULE'],
              :cfr => {:title => '45', :part => '745'}
        })
        search.summary.should == "Documents matching 'fishing', of type Rule or Proposed Rule, and affecting 45 CFR 745"
      end
    end

  end

  context "Elasticsearch query definition" do

    it "integrates a basic #with attribute" do
      search = EsEntrySearch.new(conditions: {significant: 1})

      expect(search.send(:search_options)).to eq(
        {:size=>EsApplicationSearch::DEFAULT_RESULTS_PER_PAGE,
          :from=>0,
          :query=>
           {:function_score=>
             {:query=>
               {:bool=>
                 {:must=>[{:exists=>{:field=>"document_number"}}],
                  :filter=>[{:bool=>{:filter=>{:term=>{:significant=>true}}}}]}},
              :functions=>
               [{:gauss=>
                  {:publication_date=>
                    {:origin=>"now", :scale=>"365d", :offset=>"30d", :decay=>"0.5"}}}],
              :boost_mode=>"multiply"}},
              :sort => [
                {:_score=>{:order=>"desc"}},
                {:publication_date=>{:order=>"desc"}}
              ],
              :_source => {excludes: ["full_text", "full_text_embedding"]}}
      )
    end

    it "builds the expected search with multiple attributes correctly" do
      agency = Factory(:agency, slug: 'antitrust-division')

      search = EsEntrySearch.new(
        conditions: {
          presidential_document_type: ['determination', 'executive_order'],
        }
      )

      expect(search.send(:search_options)).to eq(
        {:from=>0,
          :query=>
           {:function_score=>
             {:boost_mode=>"multiply",
              :functions=>
               [{:gauss=>
                  {:publication_date=>
                    {:decay=>"0.5", :offset=>"30d", :origin=>"now", :scale=>"365d"}}}],
              :query=>
               {:bool=>
                 {:filter=>
                   [{:bool=>
                      {:filter=>{:terms=>{:presidential_document_type_id=>[1, 2]}}}}],
                      :must=>[{:exists=>{:field=>"document_number"}}]}}}},
          :size=>EsApplicationSearch::DEFAULT_RESULTS_PER_PAGE,
          :sort => [
            {:_score=>{:order=>"desc"}},
            {:publication_date=>{:order=>"desc"}}
          ],
          :_source => {excludes: ["full_text", "full_text_embedding"]}}
      )
    end

    it "handles less-than queries" do
      search = EsEntrySearch.new(:conditions => {:publication_date => {:gte => '2000-01-01', :lte => '2049-01-01'}})

      expect(search.send(:search_options)).to eq(
        {:from=>0,
          :query=>
           {:function_score=>
             {:boost_mode=>"multiply",
              :functions=>
               [{:gauss=>
                  {:publication_date=>
                    {:decay=>"0.5", :offset=>"30d", :origin=>"now", :scale=>"365d"}}}],
              :query=>
               {:bool=>
                 {:filter=>
                   [{:range=>
                      {:publication_date=>{:gte=>"2000-01-01", :lte=>"2049-01-01"}}}],
                    :must=>[{:exists=>{:field=>"document_number"}}]}}}},
          :size=>20,
          :sort => [
            {:_score=>{:order=>"desc"}},
            {:publication_date=>{:order=>"desc"}}
          ],
          :_source => {excludes: ["full_text", "full_text_embedding"]}}
      )
    end

  end

  context "Elasticsearch retrieval" do

    before(:each) do
      $entry_repository.create_index!(force: true)
    end

    context "autocomplete" do
      it "retrieves a basic autocomplete string and exludes one appropriately" do
        entry_1 = build_entry_double(id: 1, search_term_completion: 'Fish are an aquatic species', )
        entry_2 = build_entry_double(id: 2, search_term_completion: 'Whales are an aquatic species', )
        Entry.bulk_index([entry_1, entry_2], refresh: true)

        result = EsEntrySearch.autocomplete("fish")
        expect(result).to eq(["Fish are an aquatic species"])
      end
    end

    context "full object characteristics" do

      it "does not retrieve nil document numbers by default" do
        entry = Entry.create!(
          document_number: nil,
          signing_date: Date.new(1993,12,29),
          title: 'fish',
        )
        Entry.bulk_index([entry], refresh: true)
        search = EsEntrySearch.new(conditions: {term: 'fish'})

        expect(search.results.count).to eq(0)
      end

      it "retrieves corrections" do
        entry = Factory.create(
          :entry,
          title: 'fish',
        )
        correction = Factory.create(
          :entry,
          correction_of_id: entry.id
        )

        Entry.bulk_index([entry], refresh: true)
        search = EsEntrySearch.new(conditions: {term: 'fish'})

        result = search.results.first
        expect(result).to have_attributes(
          corrections: ["http://www.fr2.local:8081/api/v1/documents/#{correction.document_number}"]
        )
      end

      it "returns the same attributes as an active record object for cfr references" do
        another_entry = Factory.build(
          :entry,
          title: 'fish',
        )
        entry_cfr_reference = EntryCfrReference.new(title: 14, part: 71)
        another_entry.entry_cfr_references = [entry_cfr_reference]

        entries = [
          another_entry
        ]

        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: 'fish'})
        result = search.results.first
        expect(result).to have_attributes(
          cfr_references: [{
            :title        => entry_cfr_reference.title,
            :part         => entry_cfr_reference.part,
            :chapter      => entry_cfr_reference.chapter,
            :citation_url => nil
          }]
        )
      end

      it "returns the same attributes as an active record object for complex agency-related attributes" do
        agency = Factory(:agency)
        agency_name = Factory(:agency_name, agency: agency)
        another_entry = Factory(
          :entry,
          title: 'fish',
          publication_date: Date.current,
          agency_names: [agency_name]
        )
        entries = [
          another_entry
        ]

        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: 'fish'})

        result = search.results.first
        expect(result).to have_attributes(
          publication_date: Date.current,
          agencies: [
            {
              "raw_name": agency_name.name,
              "name":     agency.name,
              "id":       agency.id,
              "url":      "http://www.fr2.local:8081/agencies/#{agency.slug}",
              "json_url": "http://www.fr2.local:8081/api/v1/agencies/#{agency.id}",
              "parent_id": nil,
              "slug":     agency.slug
            }
          ],
          agency_names: [agency.name]
        )
      end

    end

    context "hybrid searches" do

      it "if a non-existent pipeline is specified on bulk index, an error is thrown"

      it "can search the full_text_chunk_embeddings" do
        entries = [
          build_entry_double({full_text: "fried eggs potato", title: 'fried eggs potato', id: 777}),
          build_entry_double({full_text: "american presidency", title: 'donald trump presidency', id: 888}),
          build_entry_double({full_text: "sharks and whales", title: 'sharks and whales', id: 999}),
        ]
        Entry.bulk_index(entries, refresh: true, pipeline: OpenSearchIngestPipelineRegistrar::CHUNKING_PIPELINE_NAME)
        expect($entry_repository.count).to eq(3)

        search = EsEntrySearch.new(conditions: {term: 'united states executive office', search_type_ids: [SearchType::HYBRID.id]}) #Note that this is a domain-specific term not mentioned exactly in any of the indexed text

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([888])
      end

      it "filters out completely irrelevant results even if a k-value greater than 1 is specified" do
        entries = [
          build_entry_double({full_text: "fried eggs potato", title: 'fried eggs potato', id: 777}),
          build_entry_double({full_text: "donald trump presidency", title: 'donald trump presidency', id: 888}),
          build_entry_double({full_text: "sharks and whales", title: 'sharks and whales', id: 999}),
        ]
        Entry.bulk_index(entries, refresh: true, pipeline: OpenSearchIngestPipelineRegistrar::CHUNKING_PIPELINE_NAME)
        expect($entry_repository.count).to eq(3)

        search = EsEntrySearch.new(conditions: {term: 'asdfasdfasdfasdf', search_type_ids: [SearchType::HYBRID.id]}) #This is a completely non-sensical term.  KNN should not return anything
        allow(search).to receive(:k_value).and_return(3)

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([])
      end

      it "applies sort ordering" do
        pending("sort ordering is currently not supported with neural search, but it seems likely this will be supported as OpenSearch builds out more extensive support for  hybrid search.  At that time (perhaps Fall 2024), we should enable this spec")
        entries = [
          build_entry_double({full_text: "american presidency", title: 'donald trump presidency', id: 777, publication_date: Date.new(2020,1,1)}),
          build_entry_double({full_text: "american presidency", title: 'donald trump presidency', id: 888, publication_date: Date.new(2021,1,1)}),
          build_entry_double({full_text: "american presidency", title: 'donald trump presidency', id: 999, publication_date: Date.new(2023,1,1)}),
        ]
        Entry.bulk_index(entries, refresh: true, pipeline: OpenSearchIngestPipelineRegistrar::CHUNKING_PIPELINE_NAME)
        expect($entry_repository.count).to eq(3)

        search = EsEntrySearch.new(conditions: {term: 'united states executive office', search_type_ids: [SearchType::HYBRID.id]}, order: 'newest') #Note that this is a domain-specific term not mentioned exactly in any of the indexed text

        assert_valid_search(search)
        expect(search.results.es_ids).to eq([999, 888, 777])
      end

    end

    context "advanced search terms" do

      it "handles a combination of advanced search syntax" do
        entries = [
          build_entry_double({title: 'fried eggs potato', id: 777}),
          build_entry_double({full_text: 'fried eggs eggplant', id: 888}),
          build_entry_double({full_text: 'fried eggs eggplant frittata', id: 888}),
          build_entry_double({agency_name: 'frittata', id: 999}),
        ]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: '"fried eggs" +(eggplant | potato)'})

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([777,888])
      end

      it "handles proximity (maximum edit distance of words per ES docs) in searches" do
        entries = [
          build_entry_double({title: 'rebuilt foreign vehicular parts', id: 111}),
        ]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: '"rebuilt parts"~2'})

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([])

        search = EsEntrySearch.new(conditions: {term: '"rebuilt parts"~3'})

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([111])
      end

      it "doesn't return if a double-quoted exact phrase is supplied" do
        entries = [
          build_entry_double({title: 'robot arms', id: 111}),
        ]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: "\"arms robot\""})

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([])
      end

      it "processes negations of exact phrases correctly" do
        entries = [
          build_entry_double({title: 'FHMA', id: 111}),
        ]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: "-=FHMA"})

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array([])
      end

    end

    it "retrieves an Active Record-like collection" do
      another_entry = Factory(:entry, title: 'fish', comment_url: 'test_url')
      entries = [
        another_entry
      ]

      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {accepting_comments_on_regulations_dot_gov: 1, term: 'fish'})
      results = search.results

      assert_valid_search(search)
      expect(results.count).to eq(1)
      expect(results.first.id).to eq(another_entry.id)
    end

    it "returns the same attributes as an active record object" do
      agency = Factory(:agency)
      agency_name = Factory(:agency_name, agency: agency)
      another_entry = Factory(
        :entry,
        title: 'fish',
        publication_date: Date.current,
        agency_names: [agency_name]
      )
      entries = [
        another_entry
      ]

      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {term: 'fish'})

      result = search.results.first
      expect(result).to have_attributes(
        publication_date: Date.current,
        agencies: [
          {
            "raw_name": agency_name.name,
            "name":     agency.name,
            "id":       agency.id,
            "url":      "http://www.fr2.local:8081/agencies/#{agency.slug}",
            "json_url": "http://www.fr2.local:8081/api/v1/agencies/#{agency.id}",
            "parent_id": nil,
            "slug":     agency.slug
          }
        ]
      )
    end

    it "retrieves AR objects properly in the proper sort order" do
      entry_1 = build_entry_double(id: 1, significant: false, publication_date: Date.new(2020,3,1).to_s(:iso) )
      entry_2 = build_entry_double(id: 2, significant: false, publication_date: Date.new(2020,2,1).to_s(:iso) )
      entry_3 = build_entry_double(id: 3, significant: false, publication_date: Date.new(2020,1,1).to_s(:iso) )
      entries = [
        entry_1,
        entry_2,
        entry_3,
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {significant: 0}, order: 'oldest', per_page: 2)

      assert_valid_search(search)
      results = search.results.map(&:id)
      expect(results).to eq([entry_3.id, entry_2.id])
    end

    it "when executive_order is specified as the sort order and documents are included that do not have an executive order number, return them first" do
      entry_1 = build_entry_double(id: 1, executive_order_number: "1", publication_date: Date.new(2020,3,1).to_s(:iso))
      entry_2 = build_entry_double(id: 2, executive_order_number: nil, publication_date: Date.new(2020,3,1).to_s(:iso))
      entry_3 = build_entry_double(id: 3, executive_order_number: "2", publication_date: Date.new(2020,3,1).to_s(:iso))
      entries = [
        entry_1,
        entry_2,
        entry_3,
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {}, order: 'executive_order_number')

      assert_valid_search(search)
      results = search.results.map(&:id)
      expect(results).to eq([entry_2.id, entry_1.id, entry_3.id])
    end

    it "performs basic excerpting" do
      $entry_repository.create_index!(force: true)
      another_entry = Factory(
        :entry,
        abstract: 'fish are great.',
        title: "Fish stuff",
        raw_text: "The fish swam across the pond",
        raw_text_updated_at: Time.current
      )
      entries = [
        another_entry
      ]

      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(
        excerpts: true,
        conditions: {term: 'fish'}
      )

      assert_valid_search(search)
      result = search.results.first.excerpt
      expect(result).to eq("The <span class=\"match\">fish</span> swam across the pond")
    end

    it "performs excerpting when a double-quoted phrase is included" do
      #NOTE: Elasticsearch currently does not seem to have thte ability to highlight phrases as chunks per this github issue: https://github.com/elastic/elasticsearch/issues/29561
      $entry_repository.create_index!(force: true)
      another_entry = Factory(
        :entry,
        abstract: 'fish are great.',
        title: "Fish stuff",
        raw_text: "The fish swam across the pond",
        raw_text_updated_at: Time.current
      )
      entries = [
        another_entry
      ]

      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(
        excerpts: true,
        conditions: {term: "\"fish\""}
      )

      assert_valid_search(search)
      result = search.results.first.excerpt
      expect(result).to eq("The <span class=\"match\">fish</span> swam across the pond")
    end

    context "excerpts for multi-field mappings" do
      it "returns one excerpt for multiple hits on full_text" do
        $entry_repository.create_index!(force: true)
        entry = Factory(
          :entry,
          raw_text_updated_at: Time.current
        )

        allow(File).to receive(:file?).and_return(true)
        allow(File).to receive(:read).and_return("fish are great")
        $entry_repository.save(entry, refresh: true)

        search = EsEntrySearch.new(
          excerpts: true,
          conditions: {term: "\"fish\" great"}
        )

        assert_valid_search(search)
        result = search.results.first.excerpt
        expect(result).to eq("<span class=\"match\">fish</span> are <span class=\"match\">great</span>")
      end

    end

    it "Entry.bulk_index" do
      another_entry = Factory(:entry, title: 'fish')
      entries = [
        another_entry
      ]

      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {term: 'fish'})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq([another_entry.id])
    end

    it "handles type attribute that was formerly CRC32-processed in Sphinx" do
      entries = [
        build_entry_double({type: ["RULE"], id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {type: ["RULE", "NOTICE"]})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [111]
    end

    it "handles document_number attribute that was formerly CRC32-processed in Sphinx" do
      entries = [
        build_entry_double({document_number: "93-31907", id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {document_numbers: ["93-31907"]})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [111]
    end

    it "retrieves the expected results for a term" do
      entries = [
        build_entry_double({title: 'fish', id: 888}),
        build_entry_double({title: 'goat', id: 999})
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {term: 'fish'})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [888]
    end

    it "If no entries meet the criteria, count is zero" do
      search = EsEntrySearch.new(conditions: {significant: 1})

      assert_valid_search(search)
      expect(search.results.count).to eq 0
    end

    it "applies a basic boolean filter correctly" do
      entries = [
        build_entry_double(significant: true, id: 888),
        build_entry_double(significant: false, id: 999),
      ]
      entries.each{|entry| $entry_repository.save(entry) }
      $entry_repository.refresh_index!

      search = EsEntrySearch.new(conditions: {significant: 1})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [888]
    end

    it ".bulk_index generates a timestamp" do
      entries = [ build_entry_double(id: 888) ]
      Entry.bulk_index(entries, refresh: true)

      result = $entry_repository.find(888).indexed_at

      expect(result).to be_present
    end

    it "term searches return the entry if they contain the docket" do
      entries = [
        build_entry_double({docket_id: ['10009-69'], id: 888}),
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {term: '10009-69'})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [888]
    end

    it "term searches return the entry if they contain the regulation id number" do
      entries = [
        build_entry_double({regulation_id_number: ["1205-AB85"], id: 888}),
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {term: '1205-AB85'})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [888]
    end

    it "applies basic sort order correctly" do
      entries = [
        build_entry_double(publication_date: '2000-01-01', id: 888),
        build_entry_double(publication_date: '2000-12-31', id: 999),
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {}, order: 'newest')

      assert_valid_search(search)
      expect(search.results.es_ids).to eq([999,888])
    end

    it "applies the sort order correctly since EO numbers are now stored as strings in ES and can contain hyphenated alpha-numeric suffixes" do
      entries = [
        build_entry_double(executive_order_number: '9396', id: 666),
        build_entry_double(executive_order_number: '9395-A', id: 888),
        build_entry_double(executive_order_number: '9395', id: 777),
        build_entry_double(executive_order_number: '9395-B', id: 999),
        build_entry_double(executive_order_number: '10000', id: 555),
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {}, order: 'executive_order_number')
      expect(search.results.es_ids).to eq([777,888,999,666,555])
    end

    it "handles array attributes" do
      entries = [
        entry,
        Factory(:entry, presidential_document_type_id: PresidentialDocumentType::DETERMINATION.id)
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(
        conditions: {
          presidential_document_type: ['determination'],
        }
      )

      assert_valid_search(search)
      expect(search.results.count).to eq 1
    end

    it "handles executive_order_number search" do
      entries = [
        entry,
        Factory(
          :entry,
          presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
          presidential_document_number: '9999'
        ),
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(
        conditions: {
          executive_order_numbers: ['9999'],
        }
      )

      assert_valid_search(search)
      expect(search.results.count).to eq 1
    end

    it "handles es multi-value attribute queries" do
      agencies = (1..2).map{ Factory.create(:agency) } #Note that actual agencies must exist in order for the search to register the filter
      entries = [
        build_entry_double({agency_ids: [agencies.first.id], id: 111 }),
        build_entry_double({agency_ids: agencies.last.id, id: 222 }),
        build_entry_double({agency_ids: [], id: 333 })
      ]
      Entry.bulk_index(entries, refresh: true)

      search = EsEntrySearch.new(conditions: {agency_ids: agencies.map(&:id) })

      assert_valid_search(search)
      expect(search.results.es_ids).to eq([111,222])
    end

    it "partially-matching docket searches succeed" do
      #NOTE: In Sphinx, docket searches were handled without with the filter's :phrase option and without a :with option.  Hence, the need for a distinct spec.
      entries = [
        build_entry_double({docket_id: ["USCG-2016-0040"], id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {docket_id: "USCG-2016"})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [111]
    end

    it "doesn't overmatch docket ids" do
      entries = [
        build_entry_double({docket_id: ["OPPT-59331"], id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {docket_id: "EPA-HQ-OPPT-2005-0049"})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq []
    end

    it "cfr single value searches succeed" do
      search = EsEntrySearch.new(conditions: {cfr: {title: 38}})
      entries = [
        build_entry_double({cfr_affected_parts: (38 * EsEntrySearch::CFR::TITLE_MULTIPLIER), id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {cfr: {title: 38}})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [111]
    end

    it "cfr range searches succeed" do
      entries = [
        build_entry_double({cfr_affected_parts: (38 * EsEntrySearch::CFR::TITLE_MULTIPLIER + 3), id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {cfr: {title: 38, part: '3-4'}})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [111]
    end

    it "RIN searches succeed" do
      entries = [
        build_entry_double({regulation_id_number: '2070-AJ57', id: 111}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {regulation_id_number: '2070-AJ57'})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq [111]
    end

    it "finds citing_document_numbers" do
      cited_entry                        = Factory(:entry)
      another_cited_entry                = Factory(:entry)
      entry_with_cited_entries           = Factory(:entry, cited_entry_ids: [cited_entry.id, another_cited_entry.id])
      another_entry_with_cited_entries   = Factory(:entry, cited_entry_ids: [cited_entry.id])
      $entry_repository.save(entry_with_cited_entries)
      $entry_repository.save(another_entry_with_cited_entries, refresh: true)

      search = EsEntrySearch.new(conditions: {citing_document_numbers: [cited_entry.document_number, another_cited_entry.document_number]})

      assert_valid_search(search)
      expect(search.results.es_ids).to match_array( [entry_with_cited_entries.id, another_entry_with_cited_entries.id])
    end

    it "doesn't fail if no citing document number is found" do
      search = EsEntrySearch.new(conditions: {citing_document_numbers: [entry.document_number]})

      expect(search.results.count).to eq(0)
    end

    it "is considered an invalid search if a document number that doesn't exist is provided" do
      search = EsEntrySearch.new(conditions: {citing_document_numbers: ['bogus_document_number']})
      expect(search.valid?).to eq(false)
    end

    it "handles geolocation search" do
      allow_any_instance_of(ApplicationSearch::PlaceSelector).to receive(:place_ids).and_return([444])
      entries = [
        build_entry_double({place_ids: [444,555], id: 999}),
      ]
      entries.each{|entry| $entry_repository.save(entry, refresh: true) }

      search = EsEntrySearch.new(conditions: {:near => {:location => "94118", :within => 50}})

      assert_valid_search(search)
      expect(search.results.es_ids).to eq([999])
    end

    context "handles date attribute queries" do
      [
        #gte, #lte, #is, #year, count
        [nil, nil, nil, 1999, 1],
        ['2000-01-01', nil, nil, nil, 1],
        [nil, '1999-12-31', nil, nil, 1],
        [nil, '12/31/1999', nil, nil, 1], #e.g. Handles non-iso format
        [nil, nil, '2000-01-01', nil, 1],
        ['1970-01-01', '1999-12-31', nil, 2000, 1],
        ['01/01/1970', '12/31/1999', nil, 2000, 1], #e.g. Handles non-iso format
      ].each do |gte, lte, is, year, count|
        it "handles dates" do
          publication_date_conditions = {
            gte: gte,
            lte: lte,
            is: is,
            year: year,
          }.reject{|k, v| v.blank?}
          entries = [
            build_entry_double({publication_date: '1999-12-31', id: 888}),
            build_entry_double({publication_date: '2000-01-01', id: 999}),
          ]

          Entry.bulk_index(entries, refresh: true)

          search = EsEntrySearch.new(conditions: {publication_date: publication_date_conditions} )

          assert_valid_search(search)
          expect(search.results.count).to eq(count)
        end
      end
    end

    context "queries on former with_all sphinx attributes" do
      it "can search by section_id" do
        section_a = Factory(:section)
        section_b = Factory(:section)
        entries = [
          build_entry_double({section_ids: [section_a.id], id: 999}),
          build_entry_double({section_ids: [section_b.id], id: 998}),
          build_entry_double({section_ids: [section_a.id, section_b.id], id: 997}),
        ]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {section_ids: [section_a.id] })

        assert_valid_search(search)
        expect(search.results.es_ids).to eq([999, 997])
      end

      it "can search by section (slug)" do
        section_a = Factory(:section)
        section_b = Factory(:section)
        entries = [
          build_entry_double({section_ids: [section_a.id], id: 999}),
          build_entry_double({section_ids: [section_b.id], id: 998}),
          build_entry_double({section_ids: [section_a.id, section_b.id], id: 997}),
        ]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {sections: [section_a.slug] })

        assert_valid_search(search)
        expect(search.results.es_ids).to eq([999, 997])
      end

      it "can search by topic_ids" do
        topic_a = Factory(:topic)
        topic_b = Factory(:topic)
        entry_a = Factory(:entry).tap do |e|
          e.topic_assignments.create(topic: topic_a)
        end
        entry_b = Factory(:entry).tap do |e|
          e.topic_assignments.create(topic: topic_b)
        end
        entries = [entry_a, entry_b]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {topic_ids: [topic_a.id] })

        assert_valid_search(search)
        expect(search.results.es_ids).to eq([entry_a.id])
      end

      it "can search by topic (slug)" do
        topic_a = Factory(:topic)
        topic_b = Factory(:topic)
        entry_a = Factory(:entry).tap do |e|
          e.topic_assignments.create(topic: topic_a)
        end
        entry_b = Factory(:entry).tap do |e|
          e.topic_assignments.create(topic: topic_b)
        end
        entries = [entry_a, entry_b]
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {topics: [topic_a.slug] })

        assert_valid_search(search)
        expect(search.results.es_ids).to eq([entry_a.id])
      end

      context "Stemming" do
        it "does not match on unrelated words with similar spelling" do
          entries = [
            build_entry_double({full_text: 'Park Statue', id: 1}),
            build_entry_double({full_text: 'Citizenship Status', id: 2}),
          ]
          Entry.bulk_index(entries, refresh: true)

          search = EsEntrySearch.new(conditions: {term: 'Status'})

          assert_valid_search(search)
          expect(search.results.es_ids).to match_array([2])
        end
      end
    end

    describe ".result_ids" do
      it "returns result IDs from all returned pages of results" do
        entries = []
        (1..100).each do |i|
          entries << build_entry_double({full_text: 'fried eggs', id: i})
        end
        Entry.bulk_index(entries, refresh: true)

        search = EsEntrySearch.new(conditions: {term: 'fried'}, per_page: 10)

        assert_valid_search(search)
        expect(search.results.es_ids).to match_array 1..10
        expect(search.result_ids).to match_array 1..100
      end
    end

    context "pagination" do
      it "can paginate through results" do
        documents = [
          FactoryGirl.create(:entry),
          FactoryGirl.create(:entry),
          FactoryGirl.create(:entry),
          FactoryGirl.create(:entry),
          FactoryGirl.create(:entry)
        ].tap do |docs|
          docs.each do |doc|
            $entry_repository.save(doc)
          end
        end
        $entry_repository.refresh_index!

        search = EsEntrySearch.new(per_page: 2, conditions: {})
        expect(search.valid?).to be true
        expect(search.results.ids).to match_array documents.first(2).map(&:id)
        expect(search.results.total_pages).to eq 3
        expect(search.results.previous_page).to eq nil

        # Next page
        page_2_search = EsEntrySearch.new(per_page: 2, page: search.results.next_page, conditions: {})
        expect(page_2_search.valid?).to be true
        expect(page_2_search.results.ids).to match_array documents[2..3].map(&:id)
        expect(page_2_search.results.total_pages).to eq 3
        expect(page_2_search.results.previous_page).to eq 1

        # Last page
        page_3_search = EsEntrySearch.new(per_page: 2, page: page_2_search.results.next_page, conditions: {})
        expect(page_3_search.valid?).to be true
        expect(page_3_search.results.ids).to match_array [documents[4].id]
        expect(page_3_search.results.total_pages).to eq 3
        expect(page_3_search.results.previous_page).to eq 2
        expect(page_3_search.results.next_page).to eq nil
      end
    end

    context "option for inclusion of pre-1994 EOs" do
      it "" do
      end


      it "in facets" do
        allow(Settings.feature_flags).to receive(:include_pre_1994_docs).and_return(true)
        entry = Factory.create(
          :entry,
          document_number: nil,
          title: 'fish',
        ) 
        Factory.create(:issue, publication_date: Date.current, completed_at: Time.current)
        Entry.bulk_index([entry], refresh: true)
        search = EsEntrySearch.new(conditions: {term: 'fish'}, include_pre_1994_docs: true)


        result = search.date_distribution(:period => :yearly).results
        expect(result["1937-01-01"]).to be_truthy
      end

      it "in normal searches" do
        allow(Settings.feature_flags).to receive(:include_pre_1994_docs).and_return(true)
        entry = Factory.create(
          :entry,
          document_number: nil,
          title: 'fish',
        ) 
        Factory.create(:issue, publication_date: Date.current, completed_at: Time.current)
        Entry.bulk_index([entry], refresh: true)
        search = EsEntrySearch.new(conditions: {term: 'fish'}, include_pre_1994_docs: true)

        expect(search.results.count).to eq(1)
      end

    end

  end

end
