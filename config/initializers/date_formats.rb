ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :month_year => "%B %Y", 
  :day_date   => "%A %d",
  :wday_and_pretty_date => lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") },
  
  # "Friday, April 22nd, 2011"
  :formal => lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y") },
  
  :pretty     => "%A, %B %d, %Y",
  :ymd        => "%Y/%m/%d",
  :ymd_no_formatting => "%Y%m%d",
  :default    => "%m/%d/%Y",
  :db_year    => "%Y-%m-%d",
  :year_month => "%Y/%m",
  :short_ordinal => lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y") }
)