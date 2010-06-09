ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :month_year => "%B %Y", 
  :year_month => "%Y%m", 
  :day_date   => "%A %d",
  :wday_and_pretty_date => lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") },
  :pretty     => "%A, %B %d, %Y",
  :ymd        => "%Y/%m/%d",
  :default    => "%m/%d/%Y",
  :db_year    => "%Y-%m-%d",
  :year_month => "%Y/%m",
  :short_ordinal => lambda { |time| time.strftime("%b #{time.day.ordinalize}, %Y") }
)