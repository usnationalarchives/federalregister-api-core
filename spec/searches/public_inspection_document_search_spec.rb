require "spec_helper"

describe "ES PI Doc Search", vcr: true do

  before(:all) do
    # $public_inspection_document_repository.create_index!(force: true)
  end

  describe 'it does stuff' do
    Factory(:public_inspection_document, publication_date: Date.current)
    binding.pry
    # search = EntrySearch.new(:conditions => {:term => "HOWDY", :significant => '1', :cfr =>{:title => '7', :part => '132'}})


    # Fab. PI docs
    #Call Index
    search = PublicInspectionDocumentSearch.new(:conditions => {:term => "test"})
  end
end
