class Api::V1::AgenciesController < ApiController
  def index
    respond_to do |wants|
      wants.json do
        agencies = Agency.all(:order => "name", :include => :children)
        data = agencies.map do |agency|
          basic_agency_data(agency).merge(:json_url => api_v1_agency_url(agency.id, :format => :json))
        end

        cache_for 1.day
        render_json_or_jsonp data
      end
    end
  end

  def show
    begin
      agency_ids = params[:id].split(',')
      if agency_ids.size > 1
        agency = Agency.find(:all, :conditions => {:id => agency_ids})
      else
        agency = Agency.find(params[:id])
      end
    rescue
      agency = Agency.find_by_slug(params[:id])
    end

    respond_to do |wants|
      wants.json do
        cache_for 1.day

        if agency
          if agency.is_a?(Array)
            render_json_or_jsonp agency.map{|a| basic_agency_data(a)}
          else
            render_json_or_jsonp basic_agency_data(agency)
          end
        else
          render text: {error: 404}.to_json, status: :not_found
        end
      end
    end
  end

  def suggestions
    respond_to do |wants|
      wants.json do
        cache_for 1.day
          agencies = Agency.named_approximately(params[:conditions][:term]).limit(10)
          render_json_or_jsonp agencies.map{|a| basic_agency_data(a)}
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
