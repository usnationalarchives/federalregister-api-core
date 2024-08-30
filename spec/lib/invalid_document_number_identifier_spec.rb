require "spec_helper"

describe InvalidDocumentNumberIdentifier do
  include described_class

  it "does not reject any known two character prefix as invalid" do
    known_two_character_prefixes = %w(00 01 02 03 04 05 06 07 08 09 20 92 93 94 95 96 97 98 99 C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 E1 E3 E4 E5 E6 E7 E8 E9 R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 X0 X1 X9 Z4 Z5 Z6 Z7 Z8 Z9)

    known_two_character_prefixes.each do |prefix|
      example_document_number = "#{prefix}-12345"
      expect(invalid_document_number?(example_document_number)).to eq(false)
    end
  end

  it "flags known bad examples as invalid" do
    known_bad_document_numbers_examples = ["88", "7486", "21", "91", "CDC-2024-0015"]

    known_bad_document_numbers_examples.each do |doc_num|
      expect(invalid_document_number?(doc_num)).to eq(true)
    end
  end

  it "does not identify good document numbers as invalid" do
    valid_document_numbers = ["C1-2010-31877", "E9-5927", "93-32034", "2024-19189"]

    valid_document_numbers.each do |doc_num|
      expect(invalid_document_number?(doc_num)).to eq(false)
    end
  end

end
