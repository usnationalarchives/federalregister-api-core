require "spec_helper"

describe "ES PI Doc Search" do

  before(:all) do
    $public_inspection_document_repository.create_index!(force: true)
  end

  let!(:public_inspection_document) do
    Factory(:public_inspection_document,
      special_filing: 1,
      publication_date: Date.new(2020,1,1),
      subject_1: 'fish',
      subject_2: 'fish',
      subject_3: 'fish'
    )
  end

  let!(:other_public_inspection_document) do
    Factory(:public_inspection_document,
      special_filing: 0,
      publication_date: Date.new(2020,1,2),
      subject_1: 'goats',
      subject_2: 'goats',
      subject_3: 'goats'
    )
  end

  it 'it does stuff' do
    serialized_document = PublicInspectionDocumentSerializer.new(public_inspection_document)
    $public_inspection_document_repository.save(serialized_document)

    other_serialized_document = PublicInspectionDocumentSerializer.new(other_public_inspection_document)
    $public_inspection_document_repository.save(other_serialized_document)

    $public_inspection_document_repository.refresh_index!

    # Fab. PI docs
    search = EsPublicInspectionDocumentSearch.new(
      :conditions => {
        :term => 'fish',
        :special_filing => 1
      }
    )

    expect(search.results.count).to eq 1
  end
end
