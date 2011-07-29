class EntrySearch::Suggestor::Date < EntrySearch::Suggestor::Base
  private
  
  def pattern
    /(\d\d?\/\d\d?\/\d\d(?:\d\d)?)/
  end
  
  def handle_match(date_str)
    begin
      @date = parse_date(date_str)
      @conditions[:publication_date] = {:is => @date.to_s}
    rescue ArgumentError
      @conditions = nil
    end
  end
  
  def parse_date(str)
    date = Date.parse(str)
    if date.year < 100
      if date.year < 30 # assume 10/15/29 is 2029; 10/15/30 is 2030
        date = date.change(:year => date.year + 2000)
      else
        date = date.change(:year => date.year + 1900)
      end
    end
    
    date
  end
end