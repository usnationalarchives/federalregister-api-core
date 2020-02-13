require "spec_helper"

describe "Elasticsearch Entry Search" do

  def build_entry_double(hsh)
    entry = double('entry')
    allow(entry).to receive(:to_hash).and_return(hsh)
    entry
  end


  let!(:entry) do
    Factory(
      :entry,
      publication_date: Date.new(2020,1,1),
      significant: 1,
    )
  end

  context "Elasticsearch query definition" do

    it "integrates a basic #with attribute" do
      search = EsEntrySearch.new(conditions: {significant: 1})

      expect(search.send(:search_options)).to eq(
        {
          query: {
            bool: {
              filter: [
                {
                  bool: {
                    filter: {
                      term: {
                        significant: true
                      }
                    }
                  }
                }
              ]
            }
          }
        }
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
        {
          query: {
            bool: {
              filter: [
                {
                  bool: {
                    filter: {
                      terms: {presidential_document_type_id: [1,2]}
                    }
                  }
                }
              ]
            }
          }
        }
      )
    end

    it "handles less-than queries" do
      search = EsEntrySearch.new(:conditions => {:publication_date => {:gte => '2000-01-01', :lte => '2049-01-01'}})

      expect(search.send(:search_options)).to eq(
        {
          query: {
            bool: {
              must: [],
              filter: [
                {
                  range: {
                    publication_date: {
                      gte: '2000-01-01',
                      lte: '2049-01-01',
                    }
                  }
                }
              ]
            }
          }
        }
      )
    end

  end

  context "Elasticsearch retrieval" do

    before(:each) do
      $entry_repository.create_index!(force: true)
    end

    it "performs a term search" do
    end

    it "applies a basic boolean filter correctly" do
      entries = [entry, Factory(:entry, significant: 0)]
      entries.each{|entry| $entry_repository.save(entry) }
      $entry_repository.refresh_index!

      search = EsEntrySearch.new(conditions: {significant: 1})

      expect(search.results.count).to eq 1
    end

    it "handles array attributes" do
      entries = [
        entry,
        Factory(:entry, presidential_document_type_id: PresidentialDocumentType::DETERMINATION.id)
      ]
      entries.each{|entry| $entry_repository.save(entry) }

      $entry_repository.refresh_index! #TODO: Is this refresh needed?

      search = EsEntrySearch.new(
        conditions: {
          presidential_document_type: ['determination'],
        }
      )

      expect(search.results.count).to eq 1
    end

    it "handles Sphinx multi-value attribute queries" do
      agencies = (1..2).map{ Factory.create(:agency) } #Note that actual agencies must exist in order for the search to register the filter
      entries = [
        build_entry_double({agency_ids: agencies.first.id }),
        build_entry_double({agency_ids: agencies.last.id }),
        build_entry_double({agency_ids: [] })
      ]
      entries.each{|entry| $entry_repository.save(entry) }
      $entry_repository.refresh_index!

      search = EsEntrySearch.new(conditions: {agency_ids: agencies.map(&:id) })

      expect(search.results.count).to eq(2)
    end

    context "handles date attribute queries" do
      [
        #gte, #lte, #is, #year, count
        ['2000-01-01', nil, nil, nil, 1],
        [nil, '1999-12-31', nil, nil, 1],
        [nil, nil, '2000-01-01', nil, 1],
        ['1970-01-01', '1999-12-31', nil, 2000, 1],
      ].each do |gte, lte, is, year, count|
        it "handles dates" do
          publication_date_conditions = {
            gte: gte,
            lte: lte,
            is: is,
            year: year,
          }.reject{|k, v| v.blank?}
          entries = [
            build_entry_double({publication_date: '1999-12-31' }),
            build_entry_double({publication_date: '2000-01-01' }),
          ]

          entries.each{|entry| $entry_repository.save(entry) }
          $entry_repository.refresh_index!

          search = EsEntrySearch.new(conditions: {publication_date: publication_date_conditions} )
          expect(search.results.count).to eq(count)
        end
      end
    end

  end

end
