class Api::V1::PublicInspectionIssuesController < ApiController
  def facets
    date_facets = %w(daily)
    raise ActiveRecord::RecordNotFound unless (date_facets).include?(params[:facet])

    if required_params?
      issues = PublicInspectionIssueApiRepresentation.send(
        "#{params[:facet]}_facet",
        params[:conditions]
      )

      cache_for 1.day
      render_json_or_jsonp(issues)
    else
      render_json_or_jsonp(
        {
          :errors => 'You must supply the proper conditions, conditions[:publication_date][:gte] is required.',
          :status => 400
        }
      )
    end
  end

  private

  def required_params?
    params[:conditions] && params[:conditions][:publication_date] && params[:conditions][:publication_date][:gte]
  end
end
