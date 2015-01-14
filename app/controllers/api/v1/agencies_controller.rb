class Api::V1::AgenciesController < ApiController
  def index
    respond_to do |wants|
      wants.json do
        agencies = Agency.all(:order => "name")
        data = agencies.map do |agency|
          basic_agency_data(agency).merge(:json_url => api_v1_agency_url(agency.id, :format => :json))
        end

        cache_for 1.day
        render_json_or_jsonp data
      end
    end
  end

  def show
    respond_to do |wants|
      wants.json do
        agency = Agency.find(params[:id])

        cache_for 1.day
        render_json_or_jsonp basic_agency_data(agency)
      end
    end
  end

  private

  def basic_agency_data(agency)
    representation = AgencyApiRepresentation.new(agency)
    fields = specified_fields || AgencyApiRepresentation.all_fields
    Hash[ fields.map do |field|
      [field, representation.value(field)]
    end]
  end
end
