require "spec_helper"

describe ElasticsearchIndexer, es: true do

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
    if SETTINGS['elasticsearch']['active_record_based_retrieval']
      entry = Factory(:entry, title: "Original Title")

      $entry_repository.save(entry)
      $entry_repository.refresh_index!
      expect($entry_repository.find([entry.id]).first.send(:attributes).fetch(:title)).to eq('Original Title')

      entry.update!(title: 'New Title')
      ElasticsearchIndexer.reindex_modified_entries

      expect($entry_repository.find([entry.id]).first.send(:attributes).fetch(:title)).to eq('New Title')
    else
      entry = Factory(:entry, title: "Original Title")

      $entry_repository.save(entry)
      $entry_repository.refresh_index!

      result_1 = $entry_repository.find([entry.id]).first.title
      expect(result_1).to eq('Original Title')

      entry.update!(title: 'New Title')
      ElasticsearchIndexer.reindex_modified_entries

      result_2 = $entry_repository.find([entry.id]).first.title
      expect(result_2).to eq('New Title')
    end
  end

  it "#remove_deleted_entries does not fail " do
    entry = Factory(:entry, title: "Original Title")
    entry.destroy!

    expect{ ElasticsearchIndexer.remove_deleted_entries }.not_to raise_error
  end

end
