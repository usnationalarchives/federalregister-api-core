require 'spec_helper'

describe PublicInspectionDocument do
  describe "#to_hash" do
    it "serializes title" do
      document = described_class.new(subject_1: "one", subject_2: "two", subject_3: "three", document_number: '2011-27460')
      expect(document.to_hash[:title]).to eq "one two three"
    end

  end

  it "returns the correct attachment url" do
    skip "pending"
    attachment = File.new(Rails.root + 'spec/fixtures/empty_example_file')
    result PublicInspectionDocument.new(logo: attachment).pdf.url
    host = "https://#{Settings.s3_host_aliases.public_inspection}"
    expect(result).to start_with(host)
  end

end
