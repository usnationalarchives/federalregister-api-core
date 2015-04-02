class Api::V1::PublicInspectionIssuesController < ApiController
  def facets
    field_facets = %w(type)
    date_facets = %w(daily)
    raise ActiveRecord::RecordNotFound unless (field_facets + date_facets).include?(params[:facet])

    if required_params?(params[:facet])
      issues = PublicInspectionIssueApiRepresentation.send(
        "#{params[:facet]}_facet",
        params[:conditions]
      )

      cache_for 1.day
      render_json_or_jsonp(issues)
    else
      render_json_or_jsonp(
        {
          :errors => 'You must supply the proper conditions',
          :status => 400
        }
      )
    end
  end

  private

  def required_params?(facet)
    case facet
    when 'daily'
      params[:conditions] && params[:conditions][:publication_date] && params[:conditions][:publication_date][:gte]
    when 'type'
      params[:conditions] && params[:conditions][:publication_date] && params[:conditions][:publication_date][:is]
    end
  end
end
