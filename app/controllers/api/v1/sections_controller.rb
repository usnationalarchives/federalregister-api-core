class Api::V1::SectionsController < ApiController
  include Api::ApiSectionHelper

  def index
    pub_date = parse_pub_date(params[:conditions]) || IssueApproval.latest_publication_date
    publication_date = pub_date <= IssueApproval.latest_publication_date ? pub_date : IssueApproval.latest_publication_date

    sections = {}

    Section.all.each do |section|
      sections[section.slug] = {
        :name => section.title
      }
    end

    cache_for 1.day
    render_json_or_jsonp(sections)

  rescue ArgumentError
    render :json => {:status => 404, :message => "Record Not Found"}, :status => 404
  end

  private

  def parse_pub_date(conditions)
    if conditions && conditions[:publication_date] && conditions[:publication_date][:is].present?
      begin
        Date.parse(params[:conditions][:publication_date][:is])
      rescue ArgumentError
        nil
      end
    end
  end
end
