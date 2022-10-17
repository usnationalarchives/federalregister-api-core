require "spec_helper"

RSpec.describe "Entries API", :type => :request, :es => true do

  it "Basic search query" do
    agency = Factory(:agency)
    agency_name = Factory(:agency_name, agency: agency)
    entry = Factory(
      :entry,
      significant: nil,
      title: 'goat',
      publication_date: Date.current,
      agency_names: [agency_name],
      granule_class: 'PRESDOCU',
      raw_text_updated_at: Time.current
    )
    ElasticsearchIndexer.reindex_entries(recreate_index: true)

    get "/api/v1/documents.json?per_page=20&conditions[term]=goat"
    json_response = JSON.parse(response.body)

    expect(json_response).to include(
      'count' => 1
    )

    expect(json_response.fetch('results').first).to include(
      'html_url' => "http://www.fr2.local:8081/documents/#{entry.publication_date.year}/#{sprintf('%02i',entry.publication_date.month)}/#{sprintf('%02i',entry.publication_date.day)}/#{entry.document_number}/#{entry.slug}",
      'pdf_url'  => "https://www.govinfo.gov/content/pkg/FR-#{entry.publication_date.to_s(:iso)}/pdf/#{entry.document_number}.pdf",
      'publication_date' => entry.publication_date.to_s(:iso),
      'title'    => 'goat',
      'type'     => 'Presidential Document',
      'excerpts' => "<span class=\"match\">goat</span>",
    )
  end

  it "performs an agency facet search" do
    agency_name_1 = Factory.create(:agency_name)
    agency_name_2 = Factory.create(:agency_name)
    agency_name_3 = Factory.create(:agency_name, agency: nil)
    agency_name_4 = Factory.create(:agency_name, agency: agency_name_1.agency)
    entry_1       = Factory(:entry, agency_name_ids: [agency_name_1.id, agency_name_4.id]), #ie ensure we don't double-count agency_name ids
    entry_2       = Factory(:entry, agency_name_ids: [agency_name_2.id]),
    entry_3       = Factory(:entry, agency_name_ids: [agency_name_2.id])
    entry_4       = Factory(:entry, agency_name_ids: [agency_name_3.id]) #ie doesn't break for entries with agency names not assigned to an agency
    ElasticsearchIndexer.reindex_entries(recreate_index: true)

    get "/api/v1/documents/facets/agency"
    
    result = JSON.parse(response.body)
    expect(result).to eq({
      agency_name_2.agency.slug => {count: 2, name: agency_name_2.agency.name},
      agency_name_1.agency.slug => {count: 1, name: agency_name_1.agency.name},
      #NOTE: We chose to omit entries without assigned agencies from the results
    }.as_json)
  end

  context "#show" do
    it "handles single document search queries" do
      entry = Factory(
        :entry,
        abstract: "Test document"
      )
      Factory(
        :entry,
        abstract: "Test document"
      )
      ElasticsearchIndexer.reindex_entries(recreate_index: true)

      get "/api/v1/documents/#{entry.document_number}.json"
      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        'abstract' => entry.abstract
      )
    end

    it "handles multiple document search queries" do
      entry_1 = Factory(
        :entry,
        abstract: "Test document"
      )
      entry_2 = Factory(
        :entry,
        abstract: "Test document"
      )
      Factory(
        :entry,
        abstract: "Test document"
      )
      ElasticsearchIndexer.reindex_entries(recreate_index: true)

      get "/api/v1/documents/#{entry_1.document_number},#{entry_2.document_number}.json"
      json_response = JSON.parse(response.body)
      expect(json_response.fetch("results").count).to eq(2)
    end

    context "render-via-citation-based searches" do
      it "es properly applies range conditions for volume, start page, and end page" do
        entry_1 = Factory(
          :entry,
          end_page:   59199,
          start_page: 59198,
          title:      'entry 1',
          volume:     86
        )
        entry_2 = Factory(
          :entry,
          end_page:   59198,
          start_page: 59197,
          title:      'entry 2',
          volume:     86
        )
        ElasticsearchIndexer.reindex_entries(recreate_index: true)
        get "/api/v1/documents/86%20FR%2059199%20.json" #url-encoded version of '86 FR 59199
        json_response = JSON.parse(response.body)
        expect(json_response.fetch('count')).to eq(1)
        expect(json_response.fetch('results').first).to include(
          'title' => entry_1.title
        )
      end
    end
  end

end


