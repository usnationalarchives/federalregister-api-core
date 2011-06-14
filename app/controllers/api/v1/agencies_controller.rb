class Api::V1::AgenciesController < ApiController
  def index
    respond_to do |wants|
      wants.json do
        agencies = Agency.all(:order => "name")
        data = agencies.map do |agency|
          basic_agency_data(agency).merge(:json_url => api_v1_agency_url(agency.id, :format => :json))
        end
        
        render :json => data
      end
    end
  end
  
  def show
    respond_to do |wants|
      wants.json do
        agency = Agency.find_by_id(params[:id])
        render :json => basic_agency_data(agency)
      end
    end
  end
  
  private
  
  def basic_agency_data(agency)
    agency_data = {
      :id => agency.id,
      :name => agency.name,
      :short_name => agency.short_name,
      :url => agency_url(agency),
      :description => agency.description,
      :url => agency.description,
      :recent_articles_url => api_v1_entries_url(:conditions => {:agency_ids => [agency.id]}, :order => "newest")
    }
    
    # TODO: figure out why paperclip seems so slow--600ms for this?
    if agency.logo_file_name.present?
      logo = agency.logo
      agency_data[:logo] = {
        :thumb_url => logo.url(:thumb),
        :small_url => logo.url(:small),
        :medium_url => logo.url(:medium),
      }
    end
    
    agency_data
  end
end