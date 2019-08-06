require 'spec_helper'

describe FrIndexSgmlGenerator do

  def stub_sphinx_entry_ids
    FrIndexPresenter::DocumentType.stub_any_instance(:entry_ids => Entry.all.map(&:id))
  end

  let(:eop_agency) { Factory.create(
      :agency,
      name: 'Executive Office of the President',
      short_name: 'EOP'
    ) }


  describe "basic content form" do

    before(:each) do
      eop_agency
    end

    it "puts a document without a subject under a <SUBJHED> tag and includes a page number placeholder for presidential determinations" do
      entry = Factory.create(
        :entry,
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      nil,
        toc_doc:          'Defense Production Act of 1950; Determination (Presidential Determination No. 201709 of June 13, 2017)',
        presidential_document_type_id: 1
      )
      stub_sphinx_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>D
<SUBJHED>Defense Production Act of 1950; Determination (Presidential Determination No. 201709 of June 13, 2017) (Presidential Determination No. , p.)
SGML
    end

    it "renders the &#39 encoding as an apostrophe in the subject and document contents" do
      entry = Factory.create(
        :entry,
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      'Test Subject Heading &#39',
        toc_doc:          'Test Subject 1 &#39',
        executive_order_number: 13811,
        presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id
      )
      stub_sphinx_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>T
<SUBJHED>Test Subject Heading '
<SUBJECT1>Test Subject 1 ' (EO 13811)

SGML
    end

    it "nests a document with a subject under a <SUBJHED> tag followed by a <SUBJECT1> tag" do
      entry = Factory.create(
        :entry,
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      'Committees; Establishment, Renewal, Termination, etc.:',
        toc_doc:          'Federal Advisory Committees; Continuance (EO 13811)',
        executive_order_number: 13811,
        presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id
      )
      stub_sphinx_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>C
<SUBJHED>Committees; Establishment, Renewal, Termination, etc.:
<SUBJECT1>Federal Advisory Committees; Continuance (EO 13811) (EO 13811)

SGML
    end

    it "when two entries have the same index_subject and index_doc, a parenthetical citation is provided in this format: '(EOs 13769, 13780; Proc. 9645)'" do
      common_entry_attributes = {
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      'Terrorism',
        toc_doc:          'Foreign terrorist entry into the U.S.; enhancement of vetting procedures to prevent',
      }
      Factory.create(
        :entry,
        common_entry_attributes.merge(
          executive_order_number: 13769,
          presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id
        )
      )
      Factory.create(
        :entry,
        common_entry_attributes.merge(
          executive_order_number: 13780,
          presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id
        )
      )
      Factory.create(
        :entry,
        common_entry_attributes.merge(
          executive_order_number: 13769,
          presidential_document_type_id: PresidentialDocumentType::PROCLAMATION.id,
          proclamation_number: 9645
        )
      )

      stub_sphinx_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>T
<SUBJHED>Terrorism
<SUBJECT1>Foreign terrorist entry into the U.S.; enhancement of vetting procedures to prevent (EOs 13769, 13780; Proc. 9645)

SGML
    end

    it "when two entries have blank subjects and the same index_doc, a parenthetical citation is provided in this format: 'TODO'"


  end

end
