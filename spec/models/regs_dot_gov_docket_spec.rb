require 'spec_helper'

describe RegsDotGovDocket do

  context "#default_docket?" do

    it "recognizes various formats" do
      result = RegsDotGovDocket.new(id: "OSTP_FRDOC_0001").default_docket?
      expect(result).to eq(true)
      result = RegsDotGovDocket.new(id: "NSPC_FRDOC_0001").default_docket?
      expect(result).to eq(true)
    end

    it "does not recognize non-default dockets as default" do
      result = RegsDotGovDocket.new(id: "EPA-HQ-OPPT-2023-0061").default_docket?
      expect(result).to eq(false)
    end

    it "does not recognize all dockets ending with a 0001 as default" do
      result = RegsDotGovDocket.new(id: "COLC-2023-0001").default_docket?
      expect(result).to eq(false)
    end
  end

end
