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
      pending("To handle dates")
      search = EsEntrySearch.new(:conditions => {:publication_date => {:lte => Date.current.to_s(:iso)}})

      expect(search.send(:search_options)).to eq(
        {
          query: {
            bool: {
              filter: [
                {
                  range: {
                    publication_date: {
                      lte: Date.current.to_s(:iso)
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


  end

end
