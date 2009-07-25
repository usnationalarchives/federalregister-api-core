class PotentialDateExtractor
  def self.combine(options)
    "(?:#{options.sort_by{|v| v.to_s.length}.reverse.join('|')})"
  end
  
  JUNK = combine(%w(\\s - / , )) + '+'
  
  MONTH_NAMES = %w(January February March April May June July August September October November December)
  MONTH_ABBREVIATIONS = %w(Jan Feb Mar Apr Jun Jul Aug Sep Sept Oct Nov Dec)
  MONTH = combine(MONTH_NAMES + MONTH_ABBREVIATIONS + MONTH_ABBREVIATIONS.map{|m| "#{m}."})
  
  MONTH_NUMBER_NAMES = ((1..9).to_a + (1..9).map{|n| "0#{n}"} + (10..12).to_a)
  MONTH_NUMBER = "\\b" + combine(MONTH_NUMBER_NAMES) + "\\b"
  
  DAYS_OF_MONTH_NAMES = (1..9).to_a + (1..9).map{|n| "0#{n}"} + (10..31).to_a
  ORDINALS = %w(th nd rd)
  DAY = "(?:the#{JUNK})?\\b#{combine(DAYS_OF_MONTH_NAMES)}(?:#{ORDINALS.join('|')})?\\b"
  YEAR = "\\b(?:\\d{4}|\\d{2})\\b"
  
  FORMATS = [
    MONTH + JUNK + DAY,
    MONTH + JUNK + DAY + JUNK + YEAR,
    MONTH_NUMBER + '/' + DAY + '/' + YEAR,
  ]
  
  def self.extract(text)
    if text.nil?
      return []
    end
    
    text.scan(/(#{combine(FORMATS)})/i).flatten
  end
end

