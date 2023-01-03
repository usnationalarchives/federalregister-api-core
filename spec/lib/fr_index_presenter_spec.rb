require 'spec_helper'

describe FrIndexPresenter do
  context ".available_years" do
    it "does not include the next year as an available year when not appropriate" do
      allow(Date).to receive(:today).and_return(Date.new(2022,12,29))
      FactoryGirl.create(:issue, publication_date: '2022-12-29')

      result = FrIndexPresenter.available_years
      expect(result).not_to include(2023)
    end

    it "includes the next year as an available year when run just before the end of the year" do
      allow(Date).to receive(:today).and_return(Date.new(2022,12,30))
      FactoryGirl.create(:issue, publication_date: '2023-01-03')

      result = FrIndexPresenter.available_years
      expect(result).to include(2023)
    end
  end

end
