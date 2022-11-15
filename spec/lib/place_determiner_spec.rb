require 'spec_helper'

describe PlaceDeterminer do
  before(:each) do
    Settings.stub_chain(:open_calais,:throttle,:per).and_return(0)
  end

  it "creates a single segment if the file size is under #{PlaceDeterminer::MAX_OPEN_CALAISE_FILE_SIZE_IN_KILOBYTES}" do
    determiner = described_class.new
    entry = double("Entry", raw_text: "Test text", raw_text_file_path: "invalid_file_path")
    allow(File).to receive(:size).and_return(90000)

    determiner.instance_variable_set(:@entry, entry)

    
    expect(determiner.send(:chunks)).to eq(1)
    expect(determiner.send(:entry_text_segments)).to eq(["Test text"])
  end

  it "creates multiple segments if the file size is over #{PlaceDeterminer::MAX_OPEN_CALAISE_FILE_SIZE_IN_KILOBYTES}" do
    determiner = described_class.new
    entry = double("Entry", raw_text: "Lorem ipsum dolor sit ametLorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Tortor at auctor urna nunc.", raw_text_file_path: "invalid_file_path")
    allow(File).to receive(:size).and_return(160000)

    determiner.instance_variable_set(:@entry, entry)

    result = determiner.send(:chunks)
    expect(result).to eq(2)
    expect(determiner.send(:entry_text_segments)).to eq([
      "Lorem ipsum dolor sit ametLorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit amet,Lorem ipsum dolor sit a",
      "met,Lorem ipsum dolor sit amet,, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Tortor at auctor urna nunc."]
    )
  end

  it "does not create a single character segment (eg ['Test', ' tex', 't']) when the number of supplied characters is odd" do
    determiner = described_class.new
    entry = double("Entry", raw_text: "Test text", raw_text_file_path: "invalid_file_path")
    allow(File).to receive(:size).and_return(170000)

    determiner.instance_variable_set(:@entry, entry)

    
    expect(determiner.send(:chunks)).to eq(2)
    expect(determiner.send(:entry_text_segments)).to eq(["Test ","text"])
  end

end
