require 'spec_helper'

describe DeltaAuditor do

  it "does not take into account deleted entry records" do
    entry_1 = Factory(:entry, delta: true)
    entry_2 = Factory(:entry, delta: true)
    # Entry change records are created via callback

    entry_2.destroy!

    expect{DeltaAuditor.perform}.not_to raise_error
  end

  it "does not run if disabled" do
    DeltaAuditor.disabled = true
    expect(Entry).not_to receive(:where)
    DeltaAuditor.perform
  end

end
