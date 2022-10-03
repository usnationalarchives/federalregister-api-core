class Api::V1::DocumentationController < ApiController
  layout false

  def attributes
    @fields = case params[:type]
              when 'articles'
                EntrySerializer.api_fields
              when 'public-inspection-documents'
                PublicInspectionDocumentSerializer.api_fields
              when 'agencies'
                AgencyApiRepresentation.all_fields
              else
                raise ActiveRecord::RecordNotFound
              end
  end

  def show
    respond_to do |wants|
      wants.json do
        data = YAML.load(ERB.new(File.read("#{Rails.root}/data/open_api_v3.yml")).result)
        render_json_or_jsonp data
      end
    end
  end

end
