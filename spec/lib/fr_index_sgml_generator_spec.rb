require 'spec_helper'

describe FrIndexSgmlGenerator do

  def stub_es_entry_ids
    allow_any_instance_of(FrIndexPresenter::DocumentType).to receive(:entry_ids).and_return(Entry.all.map(&:id))
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

    it "puts a document without a subject under a <SUBJHED> tag" do
      entry = Factory.create(
        :entry,
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      nil,
        toc_doc:          'Defense Production Act of 1950; Determination (Presidential Determination No. 201709 of June 13, 2017)',
        presidential_document_type_id: 1
      )
      stub_es_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>D
<SUBJHED>Defense Production Act of 1950; Determination (Presidential Determination No. 201709 of June 13, 2017)
SGML
    end

    it "correctly renders an apostrophe in the subject and document contents (instead of an encoded version &#39)" do
      entry = Factory.create(
        :entry,
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      "The Generals' Mess",
        toc_doc:          "Reserve Officers' Training",
        presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
        presidential_document_number: 13811
      )
      stub_es_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>T
<SUBJHED>The Generals' Mess
<SUBJECT1>Reserve Officers' Training

SGML
    end

    it "nests a document with a subject under a <SUBJHED> tag followed by a <SUBJECT1> tag" do
      entry = Factory.create(
        :entry,
        granule_class:    'PRESDOCU',
        publication_date: Date.new(2017,1,1),
        toc_subject:      'Committees; Establishment, Renewal, Termination, etc.:',
        toc_doc:          'Federal Advisory Committees; Continuance (EO 13811)',
        presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
        presidential_document_number: 13811
      )
      stub_es_entry_ids

      result = FrIndexSgmlGenerator.new(2017).perform
      result.should == <<-SGML
<INDEX>

<LRH>Title 3&mdash;The President
<RRH>Index
<HED>Index
<ALPHHD>C
<SUBJHED>Committees; Establishment, Renewal, Termination, etc.:
<SUBJECT1>Federal Advisory Committees; Continuance (EO 13811)

SGML
    end

  end

end
