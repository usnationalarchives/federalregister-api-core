require "spec_helper"

describe SectionHighlight do
  it "Clones records as expected" do
    date = Date.current - 1.day
    section = Factory(:section)
    section_2 = Factory(:section)
    entry_1 = Factory(:entry, publication_date: date)
    entry_2 = Factory(:entry, publication_date: date)
    SectionHighlight.create!(section: section, entry: entry_1, publication_date: date)
    SectionHighlight.create!(section: section, entry: entry_2, publication_date: date)
    SectionHighlight.create!(section: section_2, entry: entry_2, publication_date: date)

    Content::SectionHighlightCloner.new.clone(Date.current)

    expect(SectionHighlight.where(publication_date: date).count).to eq(3)
    expect(SectionHighlight.where(publication_date: Date.current).count).to eq(3)
  end
end
