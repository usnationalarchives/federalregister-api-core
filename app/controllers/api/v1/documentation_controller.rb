class Api::V1::DocumentationController < ApiController
  layout false

  def attributes
    @fields = case params[:type]
              when 'articles'
                EntryApiRepresentation.all_fields
              when 'public-inspection-documents'
                PublicInspectionDocumentApiRepresentation.all_fields
              when 'agencies'
                AgencyApiRepresentation.all_fields
              else
                raise ActiveRecord::RecordNotFound
              end
  end
end
