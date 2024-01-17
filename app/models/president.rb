class President < ActiveHash::Base
  self.data = [
    {
      :id => 32,
      :identifier => 'franklin-d-roosevelt',
      :full_name => "Franklin D. Roosevelt",
      :starts_on => Date.new(1933, 3, 4),
      :ends_on => Date.new(1945, 4, 12)
    },
    {
      :id => 33,
      :identifier => 'harry-s-truman',
      :full_name => "Harry S. Truman",
      :starts_on => Date.new(1945, 4, 12),
      :ends_on => Date.new(1953, 1, 20)
    },
    {
      :id => 34,
      :identifier => 'dwight-d-eisenhower',
      :full_name => "Dwight D. Eisenhower",
      :starts_on => Date.new(1953, 1, 20),
      :ends_on => Date.new(1961, 1, 20)
    },
    {
      :id => 35,
      :identifier => 'john-f-kennedy',
      :full_name => "John F. Kennedy",
      :starts_on => Date.new(1961, 1, 20),
      :ends_on => Date.new(1963, 11, 22)
    },
    {
      :id => 36,
      :identifier => 'lyndon-b-johnson',
      :full_name => "Lyndon B. Johnson",
      :starts_on => Date.new(1963, 11, 22),
      :ends_on => Date.new(1969, 1, 20)
    },
    {
      :id => 37,
      :identifier => 'richard-nixon',
      :full_name => "Richard Nixon",
      :starts_on => Date.new(1969, 1, 20),
      :ends_on => Date.new(1974, 8, 9)
    },
    {
      :id => 38,
      :identifier => 'gerald-ford',
      :full_name => "Gerald Ford",
      :starts_on => Date.new(1974, 8, 9),
      :ends_on => Date.new(1977, 1, 20)
    },
    {
      :id => 39,
      :identifier => 'jimmy-carter',
      :full_name => "Jimmy Carter",
      :starts_on => Date.new(1977, 1, 20),
      :ends_on => Date.new(1981, 1, 20)
    },
    {
      :id => 40,
      :identifier => 'ronald-reagan',
      :full_name => "Ronald Reagan",
      :starts_on => Date.new(1981, 1, 20),
      :ends_on => Date.new(1989, 1, 20)
    },
    {
      :id => 41,
      :identifier => 'george-h-w-bush',
      :full_name => "George H.W. Bush",
      :starts_on => Date.new(1989, 1, 20),
      :ends_on => Date.new(1993, 1, 20)
    },
    {
      :id => 1,
      :identifier => 'william-j-clinton',
      :full_name => "William J. Clinton",
      :mods_file_id => "WJC",
      :starts_on => Date.new(1993,1,20),
      :ends_on => Date.new(2001,1,19)
    },
    {
      :id => 2,
      :identifier => 'george-w-bush',
      :full_name => "George W. Bush",
      :mods_file_id => "GWB",
      :starts_on => Date.new(2001,1,20),
      :ends_on => Date.new(2009,1,19)
    },
    {
      :id => 3,
      :identifier => 'barack-obama',
      :full_name => "Barack Obama",
      :mods_file_id => "BHO",
      :starts_on => Date.new(2009,1,20),
      :ends_on => Date.new(2017,1,19)
    },
    {
      :id => 4,
      :identifier => 'donald-trump',
      :full_name => "Donald Trump",
      :mods_file_id => "DJT",
      :starts_on => Date.new(2017,1,20),
      :ends_on => Date.new(2021,1,19)
    },
    {
      :id => 5,
      :identifier => 'joe-biden',
      :full_name => "Joseph R. Biden Jr.",
      :mods_file_id => "JRB",
      :starts_on => Date.new(2021,1,20),
      :ends_on => Date.new(2025,1,19)
    },
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
