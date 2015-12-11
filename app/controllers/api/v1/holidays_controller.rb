class Api::V1::HolidaysController < ApiController
  def index
    holidays = Holiday.all

    if holidays
      render_json_or_jsonp( holiday_json(holidays) )
    else
      render :json => {:status => 404, :message => "Record Not Found"}, :status => 404
    end
  end

  private

  def holiday_json(holidays)
    holidays.inject({}) {|holidays, h|
      holidays[h.date.to_s(:iso)]=h.name
      holidays
    }
  end
end
