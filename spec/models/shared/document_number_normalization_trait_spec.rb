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
end
