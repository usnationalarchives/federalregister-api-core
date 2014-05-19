class President < ActiveHash::Base
  self.data = [
    {
      :id => 1,
      :identifier => 'william-j-clinton',
      :full_name => "William J. Clinton",
      :starts_on => Date.new(1993,1,20),
      :ends_on => Date.new(2001,1,19)
    },
    {
      :id => 2,
      :identifier => 'george-w-bush',
      :full_name => "George W. Bush",
      :starts_on => Date.new(2001,1,20),
      :ends_on => Date.new(2009,1,19)
    },
    {
      :id => 3,
      :identifier => 'barack-obama',
      :full_name => "Barack Obama",
      :starts_on => Date.new(2009,1,20),
      :ends_on => Date.new(2017,1,19)
    }
  ]

  def year_ranges
    return @year_ranges if @year_ranges

    @year_ranges = {}

    @year_ranges[starts_on.year] = starts_on .. starts_on.end_of_year
    (starts_on.year+1 .. ends_on.year-1).each do |year|
      @year_ranges[year] = Date.new(year,1,1) .. Date.new(year,12,31)
    end
    @year_ranges[ends_on.year] = ends_on.beginning_of_year .. ends_on
    @year_ranges
  end

  def ends_on
    if self[:ends_on] > Date.current
      Date.current
    else
      self[:ends_on]
    end
  end

  def self.in_office_on(date)
    all.find{|p| p.starts_on <= date && p.ends_on >= date} if date
  end
end
