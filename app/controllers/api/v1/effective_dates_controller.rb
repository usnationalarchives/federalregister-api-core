class Api::V1::EffectiveDatesController < ApiController

  def index
    respond_to do |wants|
      cache_for 1.day

      wants.json do
        effective_dates = EffectiveDateGenerator.new.perform(
          Date.parse(params[:start_date]),
          Date.parse(params[:end_date])
        )

        render_json_or_jsonp effective_dates
      end
    end
  end

end
