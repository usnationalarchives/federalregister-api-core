module ExecutiveOrderPresenter
  class EoCollection
    attr_reader :president, :year, :date_range

    def initialize(president, year, date_range=nil)
      @president = president
      @year = year
      @date_range ||= @president.year_ranges[@year]
    end

    def executive_orders
      Entry.executive_order.published_in(@date_range).scoped(:order => "executive_order_number DESC")
    end

    def count
      executive_orders.count
    end

    def minimum_number
      executive_orders.minimum(:executive_order_number)
    end

    def maximum_number
      executive_orders.maximum(:executive_order_number)
    end
  end

  def self.all_by_president_and_year
    President.all.reverse.map do |president|

      presidential_years = president.year_ranges.map{|year_range| EoCollection.new(president, year_range.first, year_range.second)}.sort_by(&:year).reverse
      [president, presidential_years]
    end
  end
end
