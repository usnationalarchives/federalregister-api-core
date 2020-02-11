require "spec_helper"

describe "ES PI Doc Search" do

  before(:all) do
    $public_inspection_document_repository.create_index!(force: true)
  end

  let!(:public_inspection_document) do
    Factory(:public_inspection_document, publication_date: Date.current)
  end

  it 'it does stuff' do
    # Fab. PI docs
    #Call Index
    search = EsPublicInspectionDocumentSearch.new(:conditions => {:publication_date => Date.current.to_s(:iso) })

    expect(search.results.count).to_not eq 0
  end
end
