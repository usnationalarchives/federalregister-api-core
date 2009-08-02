ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :month_year => "%B %Y", 
  :day_date   => "%A %d",
  :pretty     => "%A, %B %d, %Y",
  :ymd        => "%Y/%m/%d",
  :deafult    => "%m/%d/%Y",
  :db_year    => "%Y-%m-%d"
)