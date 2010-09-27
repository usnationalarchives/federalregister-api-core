class Holiday
  def self.find_by_date(date)
    @holiday_hash ||= YAML::load(File.open("#{RAILS_ROOT}/data/holidays.yml"))
    
    date = date.is_a?(String) ? Date.parse(date) : date
    name = @holiday_hash[date]
    if name
      new(date, name)
    else
      nil
    end
  end
  
  attr_accessor :date, :name
  
  def initialize(date, name)
    @date = date
    @name = name
  end
end