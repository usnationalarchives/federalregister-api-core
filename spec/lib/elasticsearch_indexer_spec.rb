require "spec_helper"

describe ElasticsearchIndexer do

  before(:each) do
    $entry_repository.create_index!(force: true)
  end

  it "removes deleted entries from elasticsearch" do
    entry = Factory(:entry)
    $entry_repository.save(entry)
    $entry_repository.refresh_index!

    expect($entry_repository.find([entry.id]).first).not_to be_nil

    entry.destroy!
    ElasticsearchIndexer.remove_deleted_entries
    expect($entry_repository.find([entry.id])).to eq [nil]
  end

  it "reindexes modified entries from elasticsearch" do
    entry = Factory(:entry, significant: 0)
    $entry_repository.save(entry)
    $entry_repository.refresh_index!
    expect($entry_repository.find([entry.id]).first.fetch('significant')).to eq(false)

    entry.update!(significant: 1)
    ElasticsearchIndexer.reindex_modified_entries

    expect($entry_repository.find([entry.id]).first.fetch('significant')).to eq(true)
  end

end
