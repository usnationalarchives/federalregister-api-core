class EffectiveDateGenerator
  class DateRangeTooLarge < StandardError; end

  DAY_DELAY_INTERVALS = [15, 21, 30, 35, 45, 60, 90]
  def perform(start_date, end_date)
    @start_date = start_date
    @end_date   = end_date

    prevent_large_requests!

    Hash.new.tap do |hsh|
      (start_date..end_date).each do |date|
        if anticipated_publication_date?(date)
          hsh[date.to_s(:iso)] = Hash.new.tap do |hsh|
            DAY_DELAY_INTERVALS.each do |day_delay_interval|
              hsh[day_delay_interval] = EffectiveDate.new(date, day_delay_interval).json
            end
          end
        end
      end
    end
  end


  private

  attr_reader :start_date, :end_date

  MAX_DAYS_ALLOWED = 120
  def prevent_large_requests!
    if (end_date - start_date) > MAX_DAYS_ALLOWED
      raise DateRangeTooLarge, "Request size must be smaller than #{MAX_DAYS_ALLOWED} days"
    end
  end

  WEEKEND_DATES = [0,6]
  def anticipated_publication_date?(date)
    WEEKEND_DATES.exclude?(date.wday) && Holiday.find_by_date(date).nil?
  end


  class EffectiveDate
    extend Memoist

    def initialize(start_date, delay_interval)
      @start_date     = start_date
      @delay_interval = delay_interval
      @delay_reasons  = []
    end

    def json
      {
        date:          calculated_date.iso_date,
        delay_reasons: delay_reasons.uniq
      }
    end


    private

    attr_reader :start_date, :delay_interval, :delay_reasons

    WEEKEND_DATES = [6,7]
    def calculated_date
      candidate = CandidateDate.new(start_date.advance(days: delay_interval))

      while !candidate.valid?
        if candidate.weekend?
          delay_reasons << 'weekend'
        end

        if candidate.holiday
          delay_reasons << candidate.holiday.name
        end
        next_day  = candidate.date.advance(days: 1)
        candidate = CandidateDate.new(next_day)
      end

      candidate
    end

    class CandidateDate
      extend Memoist

      attr_reader :date

      def initialize(date)
        @date = date
      end

      def valid?
        !weekend? && !holiday
      end

      def iso_date
        date.to_s(:iso)
      end

      def holiday
        Holiday.find_by_date(date)
      end
      memoize :holiday

      WEEKEND_DATES = [0,6]
      def weekend?
        WEEKEND_DATES.include? date.wday
      end
      memoize :weekend?

    end

  end


end
