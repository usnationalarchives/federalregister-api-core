module ExecutiveOrderPresenter
  class EoCollection
    attr_reader :president, :year, :date_range

    def initialize(president, year, date_range=nil)
      @president = president
      @year = year
      @date_range ||= @president.year_ranges[@year]
    end

    def executive_orders
      Entry.search_klass.new(:conditions => {
        :president => @president.identifier,
        :publication_date => {:year => @year},
        :type => "PRESDOCU",
        :presidential_document_type_id => 2,
        :correction => '0',
      }, :order => "executive_order_number", :per_page => 200).results(:select => "id, document_number, publication_date, signing_date, title, start_page, end_page, citation, executive_order_number, executive_order_notes").reverse
    end

    def count
      executive_orders.count
    end

    def minimum_number
      executive_orders.last.executive_order_number
    end

    def maximum_number
      executive_orders.first.executive_order_number
    end
  end

  def self.all_by_president_and_year
    President.all.to_a.reverse.map do |president|
      presidential_years = president.year_ranges.map{|year_range| EoCollection.new(president, year_range.first, year_range.second)}.sort_by(&:year).reverse
      [president, presidential_years]
    end
  end
end
