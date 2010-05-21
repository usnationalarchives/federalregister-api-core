class CfrCitationRange
  attr_accessor :title, :part_start, :part_end
  
  def name
    if part_start
      "#{title} CFR #{part_start}-#{part_end}"
    else
      "#{title} CFR"
    end
  end
  
  def includes?(title, part)
    if part_start && part.present?
      self.title == title.to_i && part.to_i >= part_start && part.to_i <= part_end
    else
      self.title == title.to_i
    end
  end
  
  class Parser
    class InvalidFormat < RuntimeError; end
    
    attr_reader :ranges
    def initialize(text)
      @text = text
      
      @ranges = []
      if text.present?
        text.each_with_index do |line, i|
          range = process_line(line, i+1)
          @ranges << range if range
        end
      end
    end
    
    private
  
    def process_line(line, line_number)
      line = remove_comments(line)
      line = remove_excess_whitespace(line)
      
      if line.present?
        match_data = line.match(/^(\d+) CFR(?: (\d+)-(\d+))?$/)
        
        raise InvalidFormat.new("could not parse line #{line_number}") unless match_data
        
        range = CfrCitationRange.new()
        range.title = match_data[1].try(:to_i)
        range.part_start = match_data[2].try(:to_i)
        range.part_end = match_data[3].try(:to_i)
        
        range
      else
        nil
      end
    end
  
    def remove_comments(line)
      line.sub(/\#.*/,'')
    end
    
    def remove_excess_whitespace(line)
      line.sub(/^\s+/,'').sub(/\s+$/, '')
    end
  end
end