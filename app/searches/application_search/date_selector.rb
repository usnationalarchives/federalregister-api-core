class ApplicationSearch::DateSelector
  class InvalidDate < ArgumentError; end

  attr_accessor :is, :gte, :lte, :year
  attr_reader :es_value, :filter_name

  def initialize(hsh)
    hsh = hsh.with_indifferent_access

    @is = hsh[:is].to_s
    @gte = hsh[:gte].to_s
    @lte = hsh[:lte].to_s
    @year = hsh[:year].to_s.to_i if hsh[:year].present?
    @valid = true

    begin
      if @is.present?
        date = Date.parse(@is.to_s)
        validate_date!(date)
        @es_value = date.to_time.utc.beginning_of_day.to_i .. date.to_time.utc.end_of_day.to_i
        @filter_name = "on #{date}"
      elsif @year.present?
        date = Date.parse("#{@year}-01-01")
        validate_date!(date)
        @es_value = date.to_time.utc.beginning_of_day.to_i .. date.end_of_year.to_time.utc.end_of_day.to_i
        @filter_name = "in #{@year}"
      else
        if @gte.present? && @lte.present?
          @filter_name = "from #{start_date} to #{end_date}"
        elsif @gte.present?
          @filter_name = "on or after #{start_date}"
        elsif @lte.present?
          @filter_name = "on or before #{end_date}"
        else
          raise InvalidDate
        end

        @es_value = start_date.to_time.utc.beginning_of_day.to_i .. end_date.to_time.utc.end_of_day.to_i
      end
    rescue ArgumentError
      @valid = false
    end
  end

  def valid?
    @valid
  end

  def date_conditions
    if @is.present?
      date = Date.parse(@is.to_s)
      {
        lte: date.to_s(:iso),
        gte: date.to_s(:iso),
      }
    elsif @year.present?
      date = Date.parse("#{@year}-01-01")
      {
        gte: "#{date.year}-01-01",
        lte: "#{date.year}-12-31",
      }
    else
      if @gte.present? || @lte.present?
        # no-op
      else
        raise InvalidDate
      end

      {
        gte: start_date.to_s(:iso),
        lte: end_date.to_s(:iso),
      }
    end
  end

  private

  def validate_date!(date)
    if date.year > 9999
      raise ArgumentError
    end
  end

  def start_date
    if @gte.present?
      date = Date.parse(@gte)
      validate_date!(date)
      date
    else
      Date.parse('1994-01-01')
    end
  end

  def end_date
    if @lte.present?
      date = Date.parse(@lte)
      validate_date!(date)
      date
    else
      Date.current + 10.years
    end
  end
end
