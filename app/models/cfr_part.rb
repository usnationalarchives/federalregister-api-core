class CfrPart < ApplicationModel
  validates_presence_of :year, :title, :part, :volume
  validates_uniqueness_of :part, :scope => [:year, :title]

  # The annual update cycle is as follows: titles 1-16 are revised as of January 1; titles 17-27 are revised as of April 1; titles 28-41 are revised as of July 1; and titles 42-50 are revised as of October 1.
  EDITION_SCHEDULE = {
    1..16  => '01-01',
    17..27 => '04-01',
    28..41 => '07-01',
    42..50 => '10-01',
  }

  def self.find_all_candidates(date, title, part)
    where(:year => candidate_years(date, title), :title => title, :part => part)
  end

  def self.candidate_years(date, title)
   EDITION_SCHEDULE.each_pair do |title_range, month_and_day|
      if title_range.include?(title.to_i)
        issue_date = Date.parse("#{date.year}-#{month_and_day}")
        if issue_date < date
          return [date.year, date.year - 1]
        else
          return [date.year - 1, date.year - 2]
        end
      end
    end

    nil
  end
end
