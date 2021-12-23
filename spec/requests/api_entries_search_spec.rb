require "spec_helper"

RSpec.describe "Entries API", :type => :request do

  it "Basic search query" do
    agency = Factory(:agency)
    agency_name = Factory(:agency_name, agency: agency)
    entry = Factory(
      :entry,
      significant: nil,
      title: 'goat',
      publication_date: Date.current,
      agencies: [agency],
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


