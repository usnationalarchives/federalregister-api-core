require "spec_helper"

describe Content::EntryImporter do 

  context "DATES" do

    it "imports DATES section from bulk data" do
      # XML from 00-33168
      xml = <<-XML
        <RULE>
          <DATES>
            <HD SOURCE="HED">DATES: </HD>
            <P>
            This regulation is effective December 29, 2000. Objections and requests for hearings, identified by docket control number OPP-301093, must be received by EPA on or before February 27, 2001.
            </P>
          </DATES>
        </RULE>
      XML
      stubbed_bulkdata_node = Nokogiri::XML(xml).root

      importer = described_class.new(
        bulkdata_node: stubbed_bulkdata_node,
        date: Date.new(2100,1,1),
        document_number: "2100-1"
      )
      expect(importer.xml_based_dates).to eq("This regulation is effective December 29, 2000. Objections and requests for hearings, identified by docket control number OPP-301093, must be received by EPA on or before February 27, 2001.")
    end

    it "removes all newlines and applies page breaks to paragraph tags" do
      # XML from 2024-05508
      xml = <<-XML
        <NOTICE>
          <DATES>
            <HD SOURCE="HED">DATES:</HD>
            <P>
            This notice announces the opening of a 90-day comment period for the Draft RMPA/EIS beginning with the date following the Environmental Protection Agency's (EPA) publication of its Notice of Availability (NOA) in the
            <E T="04">Federal Register</E>
            . The EPA usually publishes its NOAs on Fridays.
            </P>
            <P>
            To afford the BLM the opportunity to consider comments in the Proposed RMPA/Final EIS, please ensure your comments are received prior to the close of the 90-day comment period or 15 days after the last public meeting, whichever is later.
            </P>
            <P>
            This notice also announces the opening of a 60-day comment period for ACECs. The BLM must receive your ACEC-related comments by May 14, 2024.
            </P>
            <P>
            The BLM will hold two virtual public meetings and 11 in-person public meetings throughout the planning area. The specific dates and locations of these meetings will be announced at least 15 days in advance through the ePlanning page (see
            <E T="02">ADDRESSES</E>
            ) and media releases.
            </P>
          </DATES>
        </NOTICE>
      XML
      stubbed_bulkdata_node = Nokogiri::XML(xml).root

      importer = described_class.new(
        bulkdata_node: stubbed_bulkdata_node,
        date: Date.new(2100,1,1),
        document_number: "2100-1"
      )

      expected_dates = "This notice announces the opening of a 90-day comment period for the Draft RMPA/EIS beginning with the date following the Environmental Protection Agency's (EPA) publication of its Notice of Availability (NOA) in the Federal Register . The EPA usually publishes its NOAs on Fridays.\n\nTo afford the BLM the opportunity to consider comments in the Proposed RMPA/Final EIS, please ensure your comments are received prior to the close of the 90-day comment period or 15 days after the last public meeting, whichever is later.\n\nThis notice also announces the opening of a 60-day comment period for ACECs. The BLM must receive your ACEC-related comments by May 14, 2024.\n\nThe BLM will hold two virtual public meetings and 11 in-person public meetings throughout the planning area. The specific dates and locations of these meetings will be announced at least 15 days in advance through the ePlanning page (see ADDRESSES ) and media releases."

      expect(importer.xml_based_dates).to eq(expected_dates)
    end

    it "returns nil if no DATES or EFFDATE" do
      xml = <<-XML
        <RULE>
        </RULE>
      XML
      stubbed_bulkdata_node = Nokogiri::XML(xml).root

      importer = described_class.new(
        bulkdata_node: stubbed_bulkdata_node,
        date: Date.new(2100,1,1),
        document_number: "2100-1"
      )
      expect(importer.xml_based_dates).to eq(nil)
    end

  end
  
end
