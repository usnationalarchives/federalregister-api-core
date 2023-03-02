require 'spec_helper'
describe Shared::DoesDocumentNumberNormalization do
  subject do
    klass = Class.new
    klass.include Shared::DoesDocumentNumberNormalization
    klass
  end

  describe '.normalize_document_number' do
    it "shouldn't change a number without leading zeros" do
      subject.normalize_document_number('ABCD-1234').should == 'ABCD-1234'
    end

    it "removes leading zeros" do
      subject.normalize_document_number('ABCD-001234').should == 'ABCD-1234'
    end

    it "shouldn't remove leading zeros from the initial part" do
      subject.normalize_document_number('02-001234').should == '02-1234'
    end
  end

  describe ".document_number_variants" do
    it "generates the zero-padded variants" do
      expect(subject.document_number_variants('2012-7333')).to match_array([
        '2012-7333',
        '2012-07333',
      ])
    end

    it "it generates the non-padded variants" do
      expect(subject.document_number_variants('2012-07333')).to match_array([
        '2012-7333',
        '2012-07333',
      ])
    end

  end
end
