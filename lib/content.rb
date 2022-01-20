# make csv available to importers
require 'csv'
module Content
  # returns only dates that have issues if using all or >
  def self.parse_dates(date)
    if date == 'all'
      sql = Entry.select("distinct(publication_date) AS publication_date").order("publication_date").to_sql
      dates = Entry.find_as_array(sql)
    elsif date =~ /^>/
      date = Date.parse(date.sub(/^>/, ''))
      sql = Entry.
        select("distinct(publication_date) AS publication_date").
        where(:publication_date => date .. Time.current.to_date).
        order("publication_date").
        to_sql
      dates = Entry.find_as_array(sql)
    elsif (date =~/\.{3}/) == 10 #2015-10-01...2015-11-01
      start_date, end_date = date.split('...')
      sql = Entry.
        select("distinct(publication_date) AS publication_date").
        where(:publication_date => Date.parse(start_date) ... Date.parse(end_date)).
        order("publication_date").
        to_sql
      dates = Entry.find_as_array(sql)
    elsif date =~ /^\d{4}$/
      sql = Entry.
        select("distinct(publication_date) AS publication_date").
        where(:publication_date => Date.parse("#{date}-01-01") .. Date.parse("#{date}-12-31")).
        order("publication_date").
        to_sql
      dates = Entry.find_as_array(sql)
    elsif date.present?
      dates = [date.is_a?(String) ? Date.parse(date) : date]
    else
      dates = [Time.current.to_date]
    end
  end

  # returns dates regardless of whether they have issues associated
  def self.parse_all_dates(date)
    if date =~ /^>/
      date = Date.parse(date.sub(/^>/, ''))
      dates = (date .. Time.current.to_date).to_a
    elsif (date =~/\.{3}/) == 10 #2015-10-01...2015-11-01
      start_date, end_date = date.split('...')
      dates = (Date.parse(start_date) .. Date.parse(end_date)).to_a
    elsif date.present?
      dates = [date.is_a?(String) ? Date.parse(date) : date]
    else
      dates = [Time.current.to_date]
    end
  end

  def self.run_myfr2_command(command)
    old_gemfile = ENV['BUNDLE_GEMFILE']
    Dir.chdir("../federalregister-web") do
      ENV['BUNDLE_GEMFILE'] = nil
      puts "running MyFR command: '#{command}'"
      system(command) or raise "Error when calling '#{command}'"
    end
  ensure
    ENV['BUNDLE_GEMFILE'] = old_gemfile
  end

end
