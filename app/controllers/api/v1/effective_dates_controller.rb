class Api::V1::EffectiveDatesController < ApiController

  def index
    respond_to do |wants|
      cache_for 1.day

      wants.json do
        begin
          effective_dates = EffectiveDateGenerator.new.perform(
            Date.parse(params[:start_date]),
            Date.parse(params[:end_date])
          )
          render_json_or_jsonp effective_dates
        rescue EffectiveDateGenerator::DateRangeTooLarge
          render_json_or_jsonp(
            {error: "Request size must be smaller than #{EffectiveDateGenerator::MAX_DAYS_ALLOWED} days"},
            status: 400
          )
        end
      end
    end
  end

end
